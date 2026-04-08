import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_map/flutter_map.dart' hide Marker, Polyline;
import 'package:flutter_map/flutter_map.dart' as flutter_map show Marker, Polyline;
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:intl/intl.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/provider/student_provider.dart';
import 'package:school_app/core/services/dependecyInjection.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/views/components/common_app_bar.dart';
import 'package:school_app/views/screens/bus_track/repository/bus_track_repository.dart';

class TrackingComponent extends StatefulWidget {
  final String topic;
  final bool useGoogleMaps;
  const TrackingComponent({
    super.key,
    required this.topic,
    this.useGoogleMaps = true,
  });

  @override
  TrackingComponentState createState() => TrackingComponentState();
}

class TrackingComponentState extends State<TrackingComponent>
    with SingleTickerProviderStateMixin {
  // MapTiler API Key - Replace with your actual API key
  // Get your free API key at: https://www.maptiler.com/cloud/
  // The style.json already includes English labels by default
  static const String _maptilerApiKey = 'weDjifQ8VNyyn2wlKB4d';
  
  // Cache for MapTiler style
  Future<Style>? _mapStyleFuture;
  
  String lastUpdatedTime = '';
  String clientId =
      'mqtt_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(1000)}';
  GoogleMapController? _mapController;
  MapController? _openStreetMapController; // For OpenStreetMap
  CameraPosition? _currentCameraPosition;
  late MqttServerClient client;
  LatLng? busLocation; // Nullable to handle the initial null case
  LatLng? _animatedBusLocation; // Animated location for smooth movement
  List<LatLng> busPath = []; // History of the bus path
  BitmapDescriptor _busIcon = BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueBlue,
  ); // Custom bus marker icon - default to blue
  //bool showPolyline = false; // Control polyline visibility
  bool isMapReady = false; // Flag to check if map is ready
  bool shouldMoveMap = false; // New flag to toggle map movement (default: false to allow free map exploration)
  final MapType _currentMapType = MapType.normal; // Current map type (no extra API calls)
  bool isConnecting = false; // Track connection state
  String? connectionError; // Store connection error message
  int retryCount = 0; // Track retry attempts
  static const int maxRetries = 3; // Maximum retry attempts
  bool _isDisposed = false; // Track if widget is disposed\
  static const int maxPathPoints = 50;
  double busRotation = 0;
  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>>?
  _messageSubscription;
  Timer? _statusCheckTimer;
  Timer? _noDataTimeoutTimer;
  DateTime? _lastMessageTime;
  int _totalMessagesReceived = 0;
  bool _isConnectedAndSubscribed = false;
  bool _showNoDataWarning = false;
  static const int noDataTimeoutSeconds =
      30; // Show warning after 30 seconds of no data
  Timer? _tripStatusCheckTimer;
  late String busNo;
  final BusTrackRepository _busTrackRepository = locator<BusTrackRepository>();
  static const int tripStatusCheckIntervalSeconds =
      30; // Check trip status every 30 seconds
  
  // Animation controller for smooth marker movement
  late AnimationController _animationController;
  Animation<double>? _locationAnimation;
  LatLng? _previousLocation;
  LatLng? _targetLocation;
  static const Duration _animationDuration = Duration(milliseconds: 2000); // 2 seconds for smooth movement

  @override
  void initState() {
    super.initState();
    log('🚀 [MQTT] TrackingComponent initialized');
    log('📋 [MQTT] Topic: ${widget.topic}');

    // Extract bus number from topic (format: school/transport/bus/busNo)
    final topicParts = widget.topic.split('/');
    busNo = topicParts.isNotEmpty ? topicParts.last : '';
    log('🚌 [BUS_TRACK] Extracted bus number: $busNo');

    log('🆔 [MQTT] Client ID: $clientId');
    log(
      '🌐 [MQTT] Broker: a7nalq3sp79e9-ats.iot.ap-south-1.amazonaws.com:8883',
    );

    client = MqttServerClient(
      'a7nalq3sp79e9-ats.iot.ap-south-1.amazonaws.com',
      clientId,
    );

    // Initialize animation controller for smooth marker movement
    _animationController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    );
    _animationController.addListener(_onAnimationUpdate);

    // Initialize OpenStreetMap controller
    _openStreetMapController = MapController();

    // Load MapTiler style
    _loadMapStyle();

    // Initialize bus icon
    _initializeBusIcon();

    connectToMqtt();

    // Start periodic trip status checking
    _startTripStatusCheck();
  }

  // Initialize custom bus marker icon
  Future<void> _initializeBusIcon() async {
    // Set a default blue marker immediately so marker is always visible
    _busIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
    if (mounted) {
      setState(() {});
    }
    // log('✅ [MAP] Default blue marker set immediately');

    // Create custom bus icon - this is our primary visible icon
    try {
      final customIcon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(52, 62)),
        'assets/location.png',
      );

      _busIcon = customIcon;
      // log(
      //   '✅ [MAP] Custom bus icon created successfully (120x120 blue circle with bus)',
      // );
      if (mounted) {
        setState(() {});
      }
    } catch (e, stackTrace) {
      log('❌ [MAP] Error creating custom bus icon: $e');
      log('📋 [MAP] Stack trace: $stackTrace');
      // Keep the default blue marker - it's still visible
    }

    // Skip loading from assets - the asset icon might be transparent or not suitable
    // We'll use the custom icon which is guaranteed to be visible
    // log(
    //   'ℹ️ [MAP] Using custom bus icon (skipping asset icon to ensure visibility)',
    // );
  }

  // Create a custom bus icon - perfectly sized and beautifully designed

  // Center camera on bus location
  Future<void> _centerOnBusLocation() async {
    final locationToCenter = _animatedBusLocation ?? busLocation;
    if (locationToCenter == null || !isMapReady) {
      log(
        '⚠️ [MAP] Cannot center: busLocation=${busLocation != null}, isMapReady=$isMapReady',
      );
      return;
    }

    try {
      // Use Google Maps controller if available
      if (_mapController != null) {
        await _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(locationToCenter, 17.0),
        );
        _currentCameraPosition = CameraPosition(
          target: locationToCenter,
          zoom: 17.0,
        );
        log('✅ [MAP] Camera centered on bus location (Google Maps)');
      }
      // Use OpenStreetMap controller if available
      else if (_openStreetMapController != null) {
        _openStreetMapController!.move(
          _toLatLong2(locationToCenter),
          17.0,
        );
        log('✅ [MAP] Camera centered on bus location (OpenStreetMap)');
      }
    } catch (e) {
      log('❌ [MAP] Error centering camera: $e');
    }
  }

  // Connect to the MQTT broker and subscribe to the location topic
  Future<void> connectToMqtt() async {
    if (_isDisposed || !mounted) {
      // log('⚠️ [MQTT] Widget disposed, skipping connection...');
      return;
    }

    if (isConnecting) {
      // log('⏳ [MQTT] Connection already in progress, skipping...');
      return;
    }

    // log('🔄 [MQTT] Starting connection attempt...');
    // log('📊 [MQTT] Retry count: $retryCount/$maxRetries');

    if (!mounted) return;
    setState(() {
      isConnecting = true;
      connectionError = null;
    });

    try {
      // log('⚙️ [MQTT] Configuring client settings...');
      client.port = 8883;
      client.keepAlivePeriod = 20;
      client.secure = true; // Enable SSL/TLS
      client.onDisconnected = onDisconnected;
      client.onConnected = onConnected;
      client.onSubscribed = onSubscribed;
      client.autoReconnect = false; // We'll handle reconnection manually
      // log('✅ [MQTT] Client configured: Port=8883, KeepAlive=20s, SSL=true');

      // Create SecurityContext for certificates
      // log('🔐 [MQTT] Loading SSL certificates...');
      final context = SecurityContext.defaultContext;
      try {
        // Load certificates with better error handling
        // log('📄 [MQTT] Loading Root CA certificate...');
        final rootCA = await rootBundle.load('assets/certs/AmazonRootCA1.pem');
        context.setTrustedCertificatesBytes(rootCA.buffer.asUint8List());
        // log(
        //   '✅ [MQTT] Root CA loaded successfully (${rootCA.lengthInBytes} bytes)',
        // );

        // log('📄 [MQTT] Loading client certificate...');
        final clientCert = await rootBundle.load(
          'assets/certs/certificate.pem.crt',
        );
        context.useCertificateChainBytes(clientCert.buffer.asUint8List());
        // log(
        //   '✅ [MQTT] Client certificate loaded successfully (${clientCert.lengthInBytes} bytes)',
        // );

        // log('🔑 [MQTT] Loading private key...');
        final privateKey = await rootBundle.load(
          'assets/certs/private.pem.key',
        );
        context.usePrivateKeyBytes(privateKey.buffer.asUint8List());
        // log(
        //   '✅ [MQTT] Private key loaded successfully (${privateKey.lengthInBytes} bytes)',
        // );

        client.securityContext = context;
        // log('✅ [MQTT] All certificates loaded and configured');
      } on PlatformException catch (e) {
        log('❌ [MQTT] PlatformException loading certificates: $e');
        log('📋 [MQTT] Error details: ${e.toString()}');
        if (!mounted || _isDisposed) return;
        setState(() {
          isConnecting = false;
          connectionError =
              'Certificate files not found. Please ensure certificates are in assets/certs/';
        });
        return;
      } catch (e) {
        log('❌ [MQTT] Error loading certificates: $e');
        log('📋 [MQTT] Error type: ${e.runtimeType}');
        if (!mounted || _isDisposed) return;
        setState(() {
          isConnecting = false;
          connectionError = 'Failed to load certificates: $e';
        });
        return;
      }

      // Attempt connection with timeout
      // log('🔌 [MQTT] Attempting to connect to broker...');
      final connectionStartTime = DateTime.now();
      try {
        await client.connect().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException('Connection timeout after 10 seconds');
          },
        );
        final connectionDuration = DateTime.now().difference(
          connectionStartTime,
        );
        // log(
        //   '⏱️ [MQTT] Connection attempt completed in ${connectionDuration.inMilliseconds}ms',
        // );
      } on SocketException catch (e) {
        log('❌ [MQTT] SocketException connecting to MQTT');
        log('📋 [MQTT] Error message: ${e.message}');
        log('📋 [MQTT] Error address: ${e.address}');
        log('📋 [MQTT] Error port: ${e.port}');
        log('📋 [MQTT] OS Error: ${e.osError}');

        // Retry logic with exponential backoff
        if (retryCount < maxRetries) {
          retryCount++;
          final delay = Duration(
            seconds: 2 * retryCount,
          ); // Exponential backoff
          // log(
          //   '🔄 [MQTT] Retrying connection in ${delay.inSeconds} seconds (attempt $retryCount/$maxRetries)...',
          // );
          setState(() {
            isConnecting = false;
            connectionError = 'Connection failed: ${e.message}. Retrying...';
          });
          await Future.delayed(delay);
          await connectToMqtt();
        } else {
          log('❌ [MQTT] Max retries reached. Connection failed permanently.');
          log('📊 [MQTT] Final retry count: $retryCount/$maxRetries');
          setState(() {
            isConnecting = false;
            connectionError =
                'Connection failed: ${e.message}. Max retries reached.';
          });
        }
        return;
      } on TimeoutException catch (e) {
        log('⏱️ [MQTT] TimeoutException connecting to MQTT');
        log('📋 [MQTT] Error: $e');
        log('📋 [MQTT] Timeout after 10 seconds');

        // Retry logic
        if (retryCount < maxRetries && !_isDisposed) {
          retryCount++;
          final delay = Duration(seconds: 2 * retryCount);
          log(
            '🔄 [MQTT] Retrying connection in ${delay.inSeconds} seconds (attempt $retryCount/$maxRetries)...',
          );
          if (mounted && !_isDisposed) {
            setState(() {
              isConnecting = false;
              connectionError = 'Connection timeout. Retrying...';
            });
          }
          await Future.delayed(delay);
          if (!_isDisposed && mounted) {
            await connectToMqtt();
          }
        } else {
          log('❌ [MQTT] Max retries reached for timeout. Connection failed.');
          if (mounted && !_isDisposed) {
            setState(() {
              isConnecting = false;
              connectionError =
                  'Connection timeout. Please check your internet connection. Max retries reached.';
            });
          }
        }
        return;
      } on HandshakeException catch (e) {
        log('❌ [MQTT] HandshakeException connecting to MQTT');
        log('📋 [MQTT] Error: $e');
        log(
          '🔐 [MQTT] SSL/TLS handshake failed - verify certificates are valid',
        );
        if (!mounted || _isDisposed) return;
        setState(() {
          isConnecting = false;
          connectionError =
              'SSL/TLS handshake failed. Please verify certificates are valid.';
        });
        return;
      } catch (e) {
        log('❌ [MQTT] Unexpected error connecting to MQTT');
        log('📋 [MQTT] Error: $e');
        log('📋 [MQTT] Error type: ${e.runtimeType}');

        // Retry for other connection errors
        if (retryCount < maxRetries && !_isDisposed) {
          retryCount++;
          final delay = Duration(seconds: 2 * retryCount);
          log(
            '🔄 [MQTT] Retrying connection in ${delay.inSeconds} seconds (attempt $retryCount/$maxRetries)...',
          );
          if (mounted && !_isDisposed) {
            setState(() {
              isConnecting = false;
              connectionError = 'Connection error: $e. Retrying...';
            });
          }
          await Future.delayed(delay);
          if (!_isDisposed && mounted) {
            await connectToMqtt();
          }
        } else {
          log(
            '❌ [MQTT] Max retries reached for general error. Connection failed.',
          );
          if (mounted && !_isDisposed) {
            setState(() {
              isConnecting = false;
              connectionError = 'Connection error: $e. Max retries reached.';
            });
          }
        }
        return;
      }

      // Check connection status
      final connectionState = client.connectionStatus?.state;
      log('📊 [MQTT] Connection status check: $connectionState');

      if (connectionState == MqttConnectionState.connected) {
        log('✅ [MQTT] Successfully connected to MQTT broker!');
        log('📊 [MQTT] Connection state: ${client.connectionStatus?.state}');
        log('📊 [MQTT] Return code: ${client.connectionStatus?.returnCode}');

        if (!mounted || _isDisposed) return;
        setState(() {
          isConnecting = false;
          connectionError = null;
          retryCount = 0; // Reset retry count on successful connection
        });
        log('✅ [MQTT] Connection state updated in UI');

        try {
          log('📡 [MQTT] Subscribing to topic: ${widget.topic}');
          log('📡 [MQTT] Topic length: ${widget.topic.length}');
          log('📡 [MQTT] Topic bytes: ${widget.topic.codeUnits}');
          log('📡 [MQTT] QoS level: AtMostOnce (0)');

          // Verify topic is not empty
          if (widget.topic.isEmpty) {
            throw Exception('Topic cannot be empty');
          }

          // Subscribe to the topic
          final subscription = client.subscribe(
            widget.topic,
            MqttQos.atMostOnce,
          );
          log('✅ [MQTT] Subscription request sent to topic: ${widget.topic}');
          log(
            '📊 [MQTT] Subscription message ID: ${subscription?.messageIdentifier}',
          );

          log('⏳ [MQTT] Waiting for subscription confirmation and messages...');

          // Wait a bit for subscription to be processed
          await Future.delayed(const Duration(milliseconds: 500));

          // Log subscription status
          log('📊 [MQTT] Checking subscription status after delay...');
          log('📊 [MQTT] Connection state: ${client.connectionStatus?.state}');

          // Check if subscription is registered in the client
          try {
            // The mqtt_client library stores subscriptions internally
            // We can't directly access them, but we can verify connection
            if (client.connectionStatus?.state ==
                MqttConnectionState.connected) {
              log(
                '✅ [MQTT] Connection is active, subscription should be processed',
              );
            } else {
              log(
                '⚠️ [MQTT] Connection state is not connected: ${client.connectionStatus?.state}',
              );
            }
          } catch (e) {
            log('⚠️ [MQTT] Error checking subscription status: $e');
          }

          _totalMessagesReceived = 0;
          _lastMessageTime = null;

          log('👂 [MQTT] Setting up message stream listener...');
          log(
            '👂 [MQTT] Client updates stream available: ${client.updates != null}',
          );
          log(
            '👂 [MQTT] Stream subscription state: ${client.updates?.isBroadcast}',
          );

          // Add a test to verify stream is active
          log('🧪 [MQTT] Testing message stream accessibility...');
          try {
            final testStream = client.updates;
            if (testStream != null) {
              log('✅ [MQTT] Message stream is accessible and ready');
            } else {
              log('❌ [MQTT] Message stream is NULL - this is a problem!');
            }
          } catch (e) {
            log('❌ [MQTT] Error accessing message stream: $e');
          }

          _messageSubscription = client.updates!.listen(
            (List<MqttReceivedMessage<MqttMessage>> c) {
              if (_isDisposed || !mounted) {
                // log('⚠️ [MQTT] Message received but widget disposed/unmounted');
                return;
              }

              // log(
             //     '📨 [MQTT] Raw message batch received with ${c.length} message(s)',
              // );

              // Process all messages in the batch
              for (int i = 0; i < c.length; i++) {
                try {
                  final message = c[i];
                    // log('📨 [MQTT] Processing message $i of ${c.length}');
                  // log('📨 [MQTT] Message topic: ${message.topic}');
                  // log(
                  //   '📨 [MQTT] Message payload type: ${message.payload.runtimeType}',
                  // );

                  if (message.payload is MqttPublishMessage) {
                    final MqttPublishMessage recMess =
                        message.payload as MqttPublishMessage;
                    final String topic = message.topic;
                    final String payload =
                        MqttPublishPayload.bytesToStringAsString(
                          recMess.payload.message,
                        );

                      // log(
                      //   '📋 [MQTT] Message #${_totalMessagesReceived + 1} details:',
                      // );
                      // log('   Received topic: "$topic"');
                      // log('   Expected topic: "${widget.topic}"');
                    // log('   Topic match: ${topic == widget.topic}');
                    // log('   Payload length: ${payload.length} characters');
                    log(
                      '   Payload preview: ${payload.length > 100 ? "${payload.substring(0, 100)}..." : payload}',
                    );

                    // Process messages only for our subscribed topic
                    if (topic == widget.topic) {
                      _totalMessagesReceived++;
                      _lastMessageTime = DateTime.now();

                      // Cancel timeout timer and hide warning since we received data
                      _noDataTimeoutTimer?.cancel();
                      if (_showNoDataWarning && mounted && !_isDisposed) {
                        setState(() {
                          _showNoDataWarning = false;
                        });
                      }

                      // log('✅ [MQTT] Processing message for subscribed topic');
                      // log(
                      //   '🕐 [MQTT] Message received at: ${_lastMessageTime!.toIso8601String()}',
                      // );
                      // log(
                      //   '📊 [MQTT] Total messages received: $_totalMessagesReceived',
                      // );

                      updateBusLocation(payload);
                    } else {
                      log(
                        '⚠️ [MQTT] Message received for unrelated topic: $topic',
                      );
                      log(
                        '⚠️ [MQTT] This might indicate a subscription issue or topic mismatch',
                      );
                    }
                  } else {
                    log(
                      '⚠️ [MQTT] Message payload is not MqttPublishMessage, type: ${message.payload.runtimeType}',
                    );
                  }
                } catch (e, stackTrace) {
                  log('❌ [MQTT] Error processing message $i: $e');
                  log('📋 [MQTT] Stack trace: $stackTrace');
                }
              }
            },
            onError: (error) {
              log('❌ [MQTT] Error in MQTT message stream');
              log('📋 [MQTT] Error: $error');
              log('📋 [MQTT] Error type: ${error.runtimeType}');
              log(
                '📊 [MQTT] Total messages received before error: $_totalMessagesReceived',
              );
            },
            onDone: () {
              log('⚠️ [MQTT] MQTT message stream closed');
              log(
                '📊 [MQTT] Total messages received before close: $_totalMessagesReceived',
              );
              if (_lastMessageTime != null) {
                final timeSinceLastMessage = DateTime.now().difference(
                  _lastMessageTime!,
                );
                // log(
                //   '📊 [MQTT] Time since last message: ${timeSinceLastMessage.inSeconds}s',
                // );
              }
            },
            cancelOnError: false,
          );
          log('✅ [MQTT] Message listener attached and active');

          // Mark as connected and subscribed
          if (mounted && !_isDisposed) {
            setState(() {
              _isConnectedAndSubscribed = true;
            });
          }

          // Start periodic status checks
          _startStatusCheckTimer();

          // Start timeout timer for no data
          _startNoDataTimeoutTimer();
        } catch (e, stackTrace) {
          log('❌ [MQTT] Error subscribing to topic');
          log('📋 [MQTT] Error: $e');
          log('📋 [MQTT] Error type: ${e.runtimeType}');
          log('📋 [MQTT] Stack trace: $stackTrace');
          if (!mounted || _isDisposed) return;
          setState(() {
            connectionError = 'Failed to subscribe to topic: $e';
          });
        }
      } else {
        log('❌ [MQTT] Connection failed');
        log('📊 [MQTT] Connection state: $connectionState');
        log('📊 [MQTT] Return code: ${client.connectionStatus?.returnCode}');
        if (!mounted || _isDisposed) return;
        setState(() {
          isConnecting = false;
          connectionError = 'Failed to establish connection';
        });
      }
    } catch (e, stackTrace) {
      log('❌ [MQTT] Unexpected error in connectToMqtt');
      log('📋 [MQTT] Error: $e');
      log('📋 [MQTT] Error type: ${e.runtimeType}');
      log('📋 [MQTT] Stack trace: $stackTrace');
      if (!mounted || _isDisposed) return;
      setState(() {
        isConnecting = false;
        connectionError = 'Unexpected error: $e';
      });
    }
  }

  void onConnected() {
    log('✅ [MQTT] onConnected callback triggered');
    log('📊 [MQTT] Connection state: ${client.connectionStatus?.state}');
    log('📊 [MQTT] Client ID: $clientId');
  }

  void onDisconnected() {
    log('⚠️ [MQTT] onDisconnected callback triggered');
    log('📊 [MQTT] Connection state: ${client.connectionStatus?.state}');
    log('📊 [MQTT] Retry count: $retryCount/$maxRetries');

    // Don't try to reconnect or update state if widget is disposed
    if (_isDisposed || !mounted) {
      log('⚠️ [MQTT] Widget disposed or not mounted, skipping reconnection');
      return;
    }

    try {
      setState(() {
        isConnecting = false;
        connectionError = 'Disconnected from MQTT broker';
      });
      log('📊 [MQTT] UI state updated: isConnecting=false');

      // Attempt to reconnect if not manually disconnected
      if (retryCount < maxRetries && !_isDisposed) {
        log('🔄 [MQTT] Scheduling reconnection in 2 seconds...');
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && !_isDisposed) {
            log('🔄 [MQTT] Executing scheduled reconnection...');
            connectToMqtt();
          } else {
            log(
              '⚠️ [MQTT] Skipping scheduled reconnection - widget disposed or not mounted',
            );
          }
        });
      } else {
        log(
          '❌ [MQTT] Max retries reached or widget disposed, not reconnecting',
        );
      }
    } catch (e) {
      // Ignore setState errors if widget is disposed
      log('❌ [MQTT] Error in onDisconnected callback: $e');
    }
  }

  void onSubscribed(String topic) {
    // log('✅ [MQTT] onSubscribed callback triggered');
    // log('📋 [MQTT] Successfully subscribed to topic: $topic');
    // log('📋 [MQTT] Topic length: ${topic.length}');
    // log('📋 [MQTT] Topic bytes: ${topic.codeUnits}');
    // log('📊 [MQTT] Subscription confirmed - ready to receive messages');
    // log('📊 [MQTT] Expected topic: ${widget.topic}');
    // log('📊 [MQTT] Expected topic length: ${widget.topic.length}');
    // log('📊 [MQTT] Expected topic bytes: ${widget.topic.codeUnits}');
    // log('📊 [MQTT] Topic match: ${topic == widget.topic}');

    // Detailed topic comparison
    if (topic != widget.topic) {
      log('⚠️ [MQTT] TOPIC MISMATCH DETECTED!');
      log('⚠️ [MQTT] Received topic: "$topic"');
      log('⚠️ [MQTT] Expected topic: "${widget.topic}"');
      log('⚠️ [MQTT] Character-by-character comparison:');
      for (int i = 0; i < math.max(topic.length, widget.topic.length); i++) {
        if (i >= topic.length ||
            i >= widget.topic.length ||
            topic[i] != widget.topic[i]) {
          log(
            '⚠️ [MQTT]   Position $i: received="${i < topic.length ? topic[i] : "N/A"}", expected="${i < widget.topic.length ? widget.topic[i] : "N/A"}"',
          );
        }
      }
    }

    // Verify subscription status
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      log('✅ [MQTT] Connection still active after subscription');
      if (mounted && !_isDisposed) {
        setState(() {
          _isConnectedAndSubscribed = true;
        });
      }
    } else {
      log(
        '⚠️ [MQTT] Connection state after subscription: ${client.connectionStatus?.state}',
      );
    }
  }

  void _startNoDataTimeoutTimer() {
    log('⏰ [MQTT] Starting no-data timeout timer (${noDataTimeoutSeconds}s)');
    _noDataTimeoutTimer?.cancel();
    _noDataTimeoutTimer = Timer(Duration(seconds: noDataTimeoutSeconds), () {
      if (_isDisposed || !mounted) return;

      if (_totalMessagesReceived == 0 && busLocation == null) {
        log('⚠️ [MQTT] No data timeout reached - no messages received');
        if (mounted && !_isDisposed) {
          setState(() {
            _showNoDataWarning = true;
          });
        }
      }
    });
  }

  void _startStatusCheckTimer() {
    log('⏰ [MQTT] Starting periodic status check timer (every 10 seconds)');
    _statusCheckTimer?.cancel();
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_isDisposed || !mounted) {
        log('⚠️ [MQTT] Status check skipped - widget disposed/unmounted');
        timer.cancel();
        return;
      }

      _logConnectionStatus();
    });
  }

  void _logConnectionStatus() {
    final connectionState = client.connectionStatus?.state;
    final returnCode = client.connectionStatus?.returnCode;

    log('📊 [MQTT] ========== PERIODIC STATUS CHECK ==========');
    // log('📊 [MQTT] Connection state: $connectionState');
    // log('📊 [MQTT] Return code: $returnCode');
    // log('📊 [MQTT] Topic subscribed: ${widget.topic}');
    // log('📊 [MQTT] Total messages received: $_totalMessagesReceived');

    // Check if message stream is still active
    try {
      final streamActive =
          _messageSubscription != null && !_messageSubscription!.isPaused;
      // log('📊 [MQTT] Message stream subscription active: $streamActive');
      // log(
      //   '📊 [MQTT] Message stream paused: ${_messageSubscription?.isPaused ?? "N/A"}',
      // );
    } catch (e) {
      log('⚠️ [MQTT] Error checking stream status: $e');
    }

    if (_lastMessageTime != null) {
      final timeSinceLastMessage = DateTime.now().difference(_lastMessageTime!);
      log(
        '📊 [MQTT] Last message received: ${_lastMessageTime!.toIso8601String()}',
      );
      log(
        '📊 [MQTT] Time since last message: ${timeSinceLastMessage.inSeconds}s',
      );

      if (timeSinceLastMessage.inSeconds > 30) {
        log(
          '⚠️ [MQTT] WARNING: No messages received for ${timeSinceLastMessage.inSeconds}s',
        );
        log('⚠️ [MQTT] Possible issues:');
        log('   - No data being published to topic: ${widget.topic}');
        log('   - Topic name mismatch');
        log('   - Bus device not sending location updates');
        log('   - Network connectivity issues');
      }
    } else {
      log('⚠️ [MQTT] WARNING: No messages received yet');
      log('⚠️ [MQTT] Possible issues:');
      log('   - No data being published to topic: ${widget.topic}');
      log('   - Topic subscription may have failed');
      log('   - Bus device may not be active');
    }

    // log(
    //   '📊 [MQTT] Message subscription active: ${_messageSubscription != null}',
    // );
    // log('📊 [MQTT] Widget mounted: $mounted');
    // log('📊 [MQTT] Widget disposed: $_isDisposed');
    // log('📊 [MQTT] Map ready: $isMapReady');
    // log('📊 [MQTT] Bus location set: ${busLocation != null}');
    // log('📊 [MQTT] Path points: ${busPath.length}');
    // log('📊 [MQTT] ===========================================');

    // Check if connection is still active
    if (connectionState != MqttConnectionState.connected) {
      log('❌ [MQTT] Connection lost! Current state: $connectionState');
      log('🔄 [MQTT] Attempting to reconnect...');
      if (retryCount < maxRetries) {
        connectToMqtt();
      }
    }
  }

  // Animation update listener - called on each frame during animation
  void _onAnimationUpdate() {
    if (_locationAnimation != null && _previousLocation != null && _targetLocation != null) {
      setState(() {
        // Interpolate between previous and target location
        _animatedBusLocation = _lerpLatLng(
          _previousLocation!,
          _targetLocation!,
          _locationAnimation!.value,
        );
        
        // Update rotation smoothly during animation
        if (_animatedBusLocation != null && _previousLocation != null) {
          busRotation = _bearing(_previousLocation!, _animatedBusLocation!);
        }
      });
    }
  }

  // Custom Tween for LatLng interpolation
  LatLng _lerpLatLng(LatLng begin, LatLng end, double t) {
    return LatLng(
      begin.latitude + (end.latitude - begin.latitude) * t,
      begin.longitude + (end.longitude - begin.longitude) * t,
    );
  }

  double _bearing(LatLng start, LatLng end) {
    final lat1 = start.latitude * math.pi / 180;
    final lon1 = start.longitude * math.pi / 180;
    final lat2 = end.latitude * math.pi / 180;
    final lon2 = end.longitude * math.pi / 180;

    final dLon = lon2 - lon1;

    final y = math.sin(dLon) * math.cos(lat2);
    final x =
        math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
  }

  // Helper method to convert Google Maps LatLng to latlong2 LatLng
  latlong2.LatLng _toLatLong2(LatLng latLng) {
    return latlong2.LatLng(latLng.latitude, latLng.longitude);
  }

  // Load MapTiler style
  Future<void> _loadMapStyle() async {
    _mapStyleFuture = StyleReader(
      uri: 'https://api.maptiler.com/maps/streets/style.json?key=$_maptilerApiKey',
      logger: const Logger.console(),
    ).read();
  }

  // Calculate distance between two LatLng points in meters using haversine formula
  double _calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371000; // meters
    final double lat1Rad = start.latitude * math.pi / 180;
    final double lat2Rad = end.latitude * math.pi / 180;
    final double deltaLatRad = (end.latitude - start.latitude) * math.pi / 180;
    final double deltaLonRad =
        (end.longitude - start.longitude) * math.pi / 180;

    final double a =
        math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.sin(deltaLonRad / 2) *
            math.sin(deltaLonRad / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  void updateBusLocation(String payload) {
    if (_isDisposed || !mounted) {
      log('⚠️ [MQTT] Widget disposed or not mounted, skipping location update');
      return;
    }

    try {
      // log('📍 [MQTT] Processing location update');
      // log('📦 [MQTT] Payload received: $payload');

      final List<dynamic> data = jsonDecode(payload);
      // log('✅ [MQTT] JSON parsed successfully');
      // log('📊 [MQTT] Data array length: ${data.length}');

      if (data.isEmpty || data.first is! Map<String, dynamic>) {
        log('❌ [MQTT] Invalid data format');
        log('📋 [MQTT] Data is empty: ${data.isEmpty}');
        log(
          '📋 [MQTT] First element type: ${data.isNotEmpty ? data.first.runtimeType : "N/A"}',
        );
        return;
      }

      final Map<String, dynamic> busData = data.first;
      // log('📋 [MQTT] Bus data keys: ${busData.keys.toList()}');

      final double lat = (busData['latitude'] as num).toDouble();
      final double lon = (busData['longitude'] as num).toDouble();
      final LatLng newLocation = LatLng(lat, lon);
      // log('📍 [MQTT] Parsed location: Lat=$lat, Lon=$lon');

      final timestamp = busData['time_stamp'];
      // log('🕐 [MQTT] Timestamp: $timestamp');

      // Update timestamp immediately
      setState(() {
        lastUpdatedTime = DateFormat(
          'h:mm:ss a',
        ).format(DateTime.parse(timestamp));
       // log('🕐 [MQTT] Formatted time: $lastUpdatedTime');
      });

      // Calculate distance and rotation
      double distance = 0;
      if (busLocation != null) {
        distance = _calculateDistance(busLocation!, newLocation);
        busRotation = _bearing(busLocation!, newLocation);
        // log(
        //   '📏 [MQTT] Distance from previous location: ${distance.toStringAsFixed(2)}m',
        // );
        // log(
        //   '🧭 [MQTT] Bus rotation calculated: ${busRotation.toStringAsFixed(2)}°',
        // );
      } else {
        log('📍 [MQTT] First location point - no rotation calculated');
        // For first location, set immediately without animation
        setState(() {
          busLocation = newLocation;
          _animatedBusLocation = newLocation;
          _previousLocation = newLocation;
          _targetLocation = newLocation;
        });
        
        // Add to path
        busPath.add(newLocation);
        
        // Center camera on first location (always, regardless of shouldMoveMap)
        if (isMapReady) {
          if (_mapController != null) {
            _mapController!.animateCamera(
              CameraUpdate.newLatLngZoom(newLocation, 17.0),
            );
            _currentCameraPosition = CameraPosition(
              target: newLocation,
              zoom: 17.0,
            );
          } else if (_openStreetMapController != null) {
            _openStreetMapController!.move(
              _toLatLong2(newLocation),
              17.0,
            );
          }
        }
        
        log('✅ [MQTT] First location set immediately');
        return;
      }

      // Update the target location
      _targetLocation = newLocation;
      _previousLocation = busLocation ?? newLocation;

      // Calculate animation duration based on distance (faster for shorter distances)
      // This makes the animation feel more natural
      final double normalizedDistance = math.min(distance / 100.0, 1.0); // Normalize to 0-1 for distances up to 100m
      final Duration animationDuration = Duration(
        milliseconds: (500 + (normalizedDistance * 1500)).round(), // 500ms to 2000ms
      );

      // Stop any ongoing animation
      if (_animationController.isAnimating) {
        _animationController.stop();
        // Update previous location to current animated position for smooth transition
        if (_animatedBusLocation != null) {
          _previousLocation = _animatedBusLocation;
        }
      }

      // Create new animation from current position to new position
      _locationAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut, // Smooth acceleration and deceleration
      ));

      // Start animation
      _animationController.duration = animationDuration;
      _animationController.reset();
      _animationController.forward();

      // Update bus location immediately (for path tracking)
      setState(() {
        busLocation = newLocation;
        // log('✅ [MQTT] Bus location updated in state');
        // log(
        //   '📍 [MAP] Bus location set: Lat=${newLocation.latitude}, Lon=${newLocation.longitude}',
        // );

        // Maintain bounded path history
        busPath.add(newLocation);
        if (busPath.length > maxPathPoints) {
          busPath.removeAt(0);
          // log('📊 [MQTT] Path history trimmed (max: $maxPathPoints points)');
        }
        // log('📊 [MQTT] Path history: ${busPath.length} points');
      });

      // log('✅ [MQTT] Location update completed successfully with smooth animation');
    } catch (e, stack) {
      log('❌ [MQTT] Error parsing MQTT payload');
      log('📋 [MQTT] Error: $e');
      log('📋 [MQTT] Error type: ${e.runtimeType}');
      log('📋 [MQTT] Stack trace: $stack');
    }
  }

  // Build Google Maps widget
  Widget _buildGoogleMap() {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: busLocation ?? const LatLng(25.2959397, 55.4576871),
        zoom: 17.0,
      ),
      onMapCreated: (GoogleMapController controller) async {
        log('🗺️ [MAP] Map created callback triggered');
        _mapController = controller;

        // If we already have a bus location, move camera to it
        if (busLocation != null) {
          _currentCameraPosition = CameraPosition(
            target: busLocation!,
            zoom: 17.0,
          );
          await controller.animateCamera(
            CameraUpdate.newLatLngZoom(busLocation!, 17.0),
          );
          log(
            '📷 [MAP] Camera moved to bus location: ${busLocation!.latitude}, ${busLocation!.longitude}',
          );
        } else {
          _currentCameraPosition = CameraPosition(
            target: const LatLng(25.2959397, 55.4576871),
            zoom: 17.0,
          );
        }

        setState(() {
          isMapReady = true; // Set flag when map is ready
        });
        log(
          '✅ [MAP] Map is ready - location updates can move camera',
        );
      },
      mapType: _currentMapType, // User-selectable map type (no extra API calls)
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      myLocationButtonEnabled: false,
      trafficEnabled: false,
      buildingsEnabled:
          true, // Enable 3D buildings for beautiful look (cached)
      indoorViewEnabled: false,
      compassEnabled: true, // Enable compass for better navigation
      rotateGesturesEnabled: true,
      scrollGesturesEnabled: true,
      tiltGesturesEnabled: true, // Enable tilt for 3D building view
      zoomGesturesEnabled: true,
      markers: () {
        // Use animated location if available, otherwise use regular location
        final displayLocation = _animatedBusLocation ?? busLocation;
        if (displayLocation != null) {
          return {
            Marker(
              markerId: const MarkerId('bus_location'),
              position: displayLocation,
              rotation: busRotation,
              icon: _busIcon,
              anchor: const Offset(0.5, 0.5),
              flat: true, // Makes marker rotate with map
              infoWindow: InfoWindow(
                title: 'School Bus',
                snippet:
                    'Bus No: $busNo\nLast Update: $lastUpdatedTime',
              ),
              zIndexInt: 1000, // Ensure marker is on top
              visible: true, // Explicitly set visibility
              draggable: false,
              consumeTapEvents: true, // Allow tapping the marker
            ),
          };
        } else {
          log('⚠️ [MAP] No bus location - marker not created');
          return <Marker>{};
        }
      }(),
      polylines: busPath.length >= 2
          ? {
              Polyline(
                polylineId: const PolylineId('bus_path'),
                points: busPath,
                color: Colors.blue.withValues(alpha: 0.8),
                width: 5,
              ),
            }
          : <Polyline>{},
    );
  }

  // Build OpenStreetMap widget with MapTiler vector tiles
  Widget _buildOpenStreetMap() {
    final displayLocation = _animatedBusLocation ?? busLocation;
    final initialLocation = displayLocation != null
        ? _toLatLong2(displayLocation)
        : const latlong2.LatLng(25.2959397, 55.4576871);

    // Ensure style is loaded
    if (_mapStyleFuture == null) {
      _loadMapStyle();
    }

    return FutureBuilder<Style>(
      future: _mapStyleFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final style = snapshot.data!;
        final styleCenter = style.center ?? initialLocation;
        final styleZoom = style.zoom ?? 17.0;

        return FlutterMap(
          mapController: _openStreetMapController,
          options: MapOptions(
            initialCenter: styleCenter,
            initialZoom: styleZoom,
            maxZoom: 18,
            onMapReady: () {
              log('🗺️ [MAP] OpenStreetMap ready');
              setState(() {
                isMapReady = true;
              });
              // If we already have a bus location, move camera to it
              if (busLocation != null && _openStreetMapController != null) {
                _openStreetMapController!.move(
                  _toLatLong2(busLocation!),
                  17.0,
                );
              }
            },
          ),
          children: [
            VectorTileLayer(
              theme: style.theme,
              sprites: style.sprites,
              tileProviders: style.providers,
            ),
            if (displayLocation != null)
              MarkerLayer(
                markers: [
                  flutter_map.Marker(
                    width: 52,
                    height: 62,
                    point: _toLatLong2(displayLocation),
                    child: Transform.rotate(
                      angle: busRotation * math.pi / 180,
                      child: Image.asset(
                        'assets/location.png',
                        width: 52,
                        height: 62,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            if (busPath.length >= 2)
              PolylineLayer(
                polylines: [
                  flutter_map.Polyline(
                    points: busPath.map((point) => _toLatLong2(point)).toList(),
                    strokeWidth: 5,
                    color: Colors.blue.withValues(alpha: 0.8),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: 'Bus Tracker'),
      body: busLocation == null && connectionError == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isConnectedAndSubscribed) ...[
                      const Icon(Icons.wifi, size: 64, color: Colors.green),
                      const SizedBox(height: 16),
                      const Text(
                        'Connected & Subscribed',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Topic: ${widget.topic}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      const CircularProgressIndicator(),
                      const SizedBox(height: 24),
                      const Text(
                        'Waiting for location data...',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      if (_showNoDataWarning) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.orange,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'No data received yet',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Possible reasons:',
                                style: TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                '• Bus device not sending data\n'
                                '• Bus not on active trip\n'
                                '• Topic mismatch',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ] else ...[
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      const Text(
                        'Connecting to MQTT broker...',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ],
                ),
              ),
            )
          : connectionError != null && busLocation == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Connection Error',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      connectionError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          retryCount = 0;
                          connectionError = null;
                        });
                        connectToMqtt();
                      },
                      child: const Text('Retry Connection'),
                    ),
                  ],
                ),
              ),
            )
          : Stack(
              children: [
                // Conditionally render map based on backend flag
                widget.useGoogleMaps
                    ? _buildGoogleMap()
                    : _buildOpenStreetMap(),
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: ConstColors.blueColor,
                      border: Border.all(color: ConstColors.blueColorTwo),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "Last Updated ",
                              style: TextStyle(
                                color: ConstColors.blueColorTwo,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const TextSpan(
                              text: ' ',
                              style: TextStyle(
                                color: Color(0xFF212127),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: lastUpdatedTime,
                              style: TextStyle(
                                color: ConstColors.blueColorTwo,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Row(
                    children: [
                      Checkbox(
                        value: shouldMoveMap,
                        onChanged: (bool? value) {
                          setState(() {
                            shouldMoveMap = value ?? true;
                          });
                        },
                      ),
                      const Text(
                        "Move map with live data",
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .15),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "School Bus",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text("Last update: $lastUpdatedTime"),
                          ],
                        ),
                        GestureDetector(
                          onTap: _centerOnBusLocation,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.directions_bus,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  "Live",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Map type selector button
              // Positioned(
              //     top: 70,
              //     right: 16,
              //     child: Container(
              //       decoration: BoxDecoration(
              //         color: Colors.white,
              //         borderRadius: BorderRadius.circular(12),
              //         boxShadow: [
              //           BoxShadow(
              //             color: Colors.black.withValues(alpha: 0.15),
              //             blurRadius: 8,
              //             offset: const Offset(0, 2),
              //           ),
              //         ],
              //       ),
              //       child: PopupMenuButton<MapType>(
              //         icon: const Padding(
              //           padding: EdgeInsets.all(8.0),
              //           child: Icon(Icons.layers, color: Colors.blue, size: 24),
              //         ),
              //         tooltip: 'Map Type',
              //         shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(14),
              //         ),
              //         elevation: 8,
              //         onSelected: (MapType type) {
              //           setState(() {
              //             _currentMapType = type;
              //           });
              //          // log('🗺️ [MAP] Map type changed to: $type (no extra API calls)');
              //         },
              //         itemBuilder: (BuildContext context) => [
              //           PopupMenuItem<MapType>(
              //             value: MapType.normal,
              //             child: Container(
              //               padding: const EdgeInsets.symmetric(vertical: 4),
              //               child: Row(
              //                 children: [
              //                   Icon(
              //                     Icons.map,
              //                     color: _currentMapType == MapType.normal
              //                         ? Colors.blue
              //                         : Colors.grey.shade600,
              //                     size: 22,
              //                   ),
              //                   const SizedBox(width: 12),
              //                   const Expanded(
              //                     child: Text(
              //                       'Normal',
              //                       style: TextStyle(fontSize: 16),
              //                     ),
              //                   ),
              //                   if (_currentMapType == MapType.normal)
              //                     const Icon(
              //                       Icons.check,
              //                       color: Colors.blue,
              //                       size: 20,
              //                     ),
              //                 ],
              //               ),
              //             ),
              //           ),
              //           PopupMenuItem<MapType>(
              //             value: MapType.satellite,
              //             child: Container(
              //               padding: const EdgeInsets.symmetric(vertical: 4),
              //               child: Row(
              //                 children: [
              //                   Icon(
              //                     Icons.satellite,
              //                     color: _currentMapType == MapType.satellite
              //                         ? Colors.blue
              //                         : Colors.grey.shade600,
              //                     size: 22,
              //                   ),
              //                   const SizedBox(width: 12),
              //                   const Expanded(
              //                     child: Text(
              //                       'Satellite',
              //                       style: TextStyle(fontSize: 16),
              //                     ),
              //                   ),
              //                   if (_currentMapType == MapType.satellite)
              //                     const Icon(
              //                       Icons.check,
              //                       color: Colors.blue,
              //                       size: 20,
              //                     ),
              //                 ],
              //               ),
              //             ),
              //           ),
              //           PopupMenuItem<MapType>(
              //             value: MapType.hybrid,
              //             child: Container(
              //               padding: const EdgeInsets.symmetric(vertical: 4),
              //               child: Row(
              //                 children: [
              //                   Icon(
              //                     Icons.layers,
              //                     color: _currentMapType == MapType.hybrid
              //                         ? Colors.blue
              //                         : Colors.grey.shade600,
              //                     size: 22,
              //                   ),
              //                   const SizedBox(width: 12),
              //                   const Expanded(
              //                     child: Text(
              //                       'Hybrid',
              //                       style: TextStyle(fontSize: 16),
              //                     ),
              //                   ),
              //                   if (_currentMapType == MapType.hybrid)
              //                     const Icon(
              //                       Icons.check,
              //                       color: Colors.blue,
              //                       size: 20,
              //                     ),
              //                 ],
              //               ),
              //             ),
              //           ),
              //           PopupMenuItem<MapType>(
              //             value: MapType.terrain,
              //             child: Container(
              //               padding: const EdgeInsets.symmetric(vertical: 4),
              //               child: Row(
              //                 children: [
              //                   Icon(
              //                     Icons.landscape,
              //                     color: _currentMapType == MapType.terrain
              //                         ? Colors.blue
              //                         : Colors.grey.shade600,
              //                     size: 22,
              //                   ),
              //                   const SizedBox(width: 12),
              //                   const Expanded(
              //                     child: Text(
              //                       'Terrain',
              //                       style: TextStyle(fontSize: 16),
              //                     ),
              //                   ),
              //                   if (_currentMapType == MapType.terrain)
              //                     const Icon(
              //                       Icons.check,
              //                       color: Colors.blue,
              //                       size: 20,
              //                     ),
              //                 ],
              //               ),
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              //   // Floating action button to center on bus location
                 if (busLocation != null)
                  Positioned(
                    bottom: 120,
                    right: 16,
                    child: FloatingActionButton(
                      onPressed: _centerOnBusLocation,
                      backgroundColor: Colors.blue,     
                      tooltip: 'Center on bus location',
                      child: const Icon(Icons.my_location, color: Colors.white),
                    ),
                  ),
              ],
            ),
    );
  }

  // Start periodic trip status checking
  void _startTripStatusCheck() {
    log('🔄 [TRIP_STATUS] Starting periodic trip status check');
    _tripStatusCheckTimer = Timer.periodic(
      const Duration(seconds: tripStatusCheckIntervalSeconds),
      (_) => _checkTripStatus(),
    );
  }

  // Check if the trip has ended
  Future<void> _checkTripStatus() async {
    if (_isDisposed || !mounted) {
      log(
        '⚠️ [TRIP_STATUS] Widget disposed or not mounted, skipping trip status check',
      );
      return;
    }

    try {
      log('🔍 [TRIP_STATUS] Checking trip status for bus: $busNo');

      // Get admission number from student provider
      final admissionNo = Provider.of<StudentProvider>(
        context,
        listen: false,
      ).selectedStudentModel(context).studcode;

      // Call API to get tracking data
      final result = await _busTrackRepository.getTracking(
        admissionNo: admissionNo,
      );

      if (result.isRight && result.right.status == true) {
        final liveTrips = result.right.data?.liveTrips ?? [];

        // Find the trip for this bus number
        final matchingTrips = liveTrips.where((trip) => trip.busNo == busNo);
        final trip = matchingTrips.isNotEmpty ? matchingTrips.first : null;

        if (trip == null) {
          // Trip not found in live trips - trip has ended
          log(
            '✅ [TRIP_STATUS] Bus $busNo not found in live trips - trip has ended',
          );
          _tripStatusCheckTimer?.cancel();
          _showTripEndedDialog();
        } else if (trip.endTime != null) {
          // Trip exists but has ended (endTime is not null)
          log(
            '✅ [TRIP_STATUS] Trip has ended for bus: $busNo (endTime: ${trip.endTime})',
          );
          _tripStatusCheckTimer?.cancel();
          _showTripEndedDialog();
        } else {
          log('🟢 [TRIP_STATUS] Trip is still active for bus: $busNo');
        }
      } else {
        log(
          '⚠️ [TRIP_STATUS] Failed to get tracking data: ${result.isLeft ? result.left.message : "Unknown error"}',
        );
      }
    } catch (e, stackTrace) {
      log('❌ [TRIP_STATUS] Error checking trip status: $e');
      log('📋 [TRIP_STATUS] Stack trace: $stackTrace');
    }
  }

  // Show dialog when trip ends and navigate back
  void _showTripEndedDialog() {
    if (_isDisposed || !mounted) {
      log(
        '⚠️ [TRIP_STATUS] Widget disposed or not mounted, cannot show dialog',
      );
      return;
    }

    log('📢 [TRIP_STATUS] Showing trip ended dialog');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 8),
              Text('Trip Ended'),
            ],
          ),
          content: const Text(
            'The bus trip has ended. You will be redirected back.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog
                Navigator.of(context).pop(); // Navigate back to previous page
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    log('🛑 [MQTT] TrackingComponent disposing...');
    log('📊 [MQTT] Final connection state: ${client.connectionStatus?.state}');
    log('📊 [MQTT] Final retry count: $retryCount');
    log('📊 [MQTT] Path points: ${busPath.length}');
    log('📊 [MQTT] Total messages received: $_totalMessagesReceived');

    if (_lastMessageTime != null) {
      final timeSinceLastMessage = DateTime.now().difference(_lastMessageTime!);
      log(
        '📊 [MQTT] Last message received: ${_lastMessageTime!.toIso8601String()}',
      );
      // log(
      //   '📊 [MQTT] Time since last message: ${timeSinceLastMessage.inSeconds}s',
      // );
    } else {
      log('⚠️ [MQTT] No messages were received during this session');
    }

    _isDisposed = true;
    log('✅ [MQTT] _isDisposed flag set to true');

    // Dispose animation controller
    try {
      log('🎬 [ANIMATION] Disposing animation controller...');
      _animationController.stop();
      _animationController.dispose();
      log('✅ [ANIMATION] Animation controller disposed');
    } catch (e) {
      log('❌ [ANIMATION] Error disposing animation controller: $e');
    }

    // Cancel trip status check timer
    try {
      log('⏰ [TRIP_STATUS] Cancelling trip status check timer...');
      _tripStatusCheckTimer?.cancel();
      _tripStatusCheckTimer = null;
      log('✅ [TRIP_STATUS] Trip status check timer cancelled');
    } catch (e) {
      log('❌ [TRIP_STATUS] Error cancelling trip status check timer: $e');
    }

    // Cancel status check timer
    try {
      log('⏰ [MQTT] Cancelling status check timer...');
      _statusCheckTimer?.cancel();
      _statusCheckTimer = null;
      log('✅ [MQTT] Status check timer cancelled');
    } catch (e) {
      log('❌ [MQTT] Error cancelling status check timer: $e');
    }

    // Cancel no-data timeout timer
    try {
      log('⏰ [MQTT] Cancelling no-data timeout timer...');
      _noDataTimeoutTimer?.cancel();
      _noDataTimeoutTimer = null;
      log('✅ [MQTT] No-data timeout timer cancelled');
    } catch (e) {
      log('❌ [MQTT] Error cancelling no-data timeout timer: $e');
    }

    // Cancel message subscription
    try {
      log('👂 [MQTT] Cancelling message subscription...');
      _messageSubscription?.cancel();
      _messageSubscription = null;
      log('✅ [MQTT] Message subscription cancelled');
    } catch (e) {
      log('❌ [MQTT] Error cancelling message subscription: $e');
    }

    // Clear callbacks to prevent them from being called after disposal
    try {
      log('🧹 [MQTT] Clearing MQTT callbacks...');
      client.onDisconnected = null;
      client.onConnected = null;
      client.onSubscribed = null;
      log('✅ [MQTT] MQTT callbacks cleared');
    } catch (e) {
      log('❌ [MQTT] Error clearing MQTT callbacks: $e');
    }

    // Disconnect the client
    try {
      final currentState = client.connectionStatus?.state;
      log(
        '🔌 [MQTT] Current connection state before disconnect: $currentState',
      );

      if (currentState == MqttConnectionState.connected ||
          currentState == MqttConnectionState.connecting) {
        log('🔌 [MQTT] Disconnecting MQTT client...');
        client.disconnect();
        log('✅ [MQTT] MQTT client disconnected');
      } else {
        log('ℹ️ [MQTT] Client not connected, skipping disconnect');
      }
    } catch (e) {
      log('❌ [MQTT] Error disconnecting MQTT client: $e');
    }

    // Dispose GoogleMapController
    try {
      log('🗺️ [MAP] Disposing GoogleMapController...');
      _mapController?.dispose();
      _mapController = null;
      log('✅ [MAP] GoogleMapController disposed');
    } catch (e) {
      log('❌ [MAP] Error disposing GoogleMapController: $e');
    }

    // Dispose OpenStreetMap Controller
    try {
      log('🗺️ [MAP] Disposing OpenStreetMap Controller...');
      _openStreetMapController?.dispose();
      _openStreetMapController = null;
      log('✅ [MAP] OpenStreetMap Controller disposed');
    } catch (e) {
      log('❌ [MAP] Error disposing OpenStreetMap Controller: $e');
    }

    log('✅ [MQTT] TrackingComponent disposed successfully');
    super.dispose();
  }
}
