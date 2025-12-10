import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/views/components/common_app_bar.dart';

class TrackingComponent extends StatefulWidget {
  final String topic;
  const TrackingComponent({super.key, required this.topic});

  @override
  TrackingComponentState createState() => TrackingComponentState();
}

class TrackingComponentState extends State<TrackingComponent> {
  String lastUpdatedTime = '';
  String clientId =
      'mqtt_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(1000)}';
  final MapController _mapController = MapController();
  late MqttServerClient client;
  LatLng? busLocation; // Nullable to handle the initial null case
  List<LatLng> busPath = []; // History of the bus path
  bool showPolyline = false; // Control polyline visibility
  bool isMapReady = false; // Flag to check if map is ready
  bool shouldMoveMap = true; // New flag to toggle map movement
  bool isConnecting = false; // Track connection state
  String? connectionError; // Store connection error message
  int retryCount = 0; // Track retry attempts
  static const int maxRetries = 3; // Maximum retry attempts
  bool _isDisposed = false; // Track if widget is disposed

  @override
  void initState() {
    super.initState();
    client = MqttServerClient(
      'a7nalq3sp79e9-ats.iot.ap-south-1.amazonaws.com',
      clientId,
    );
    connectToMqtt();
  }

  // Connect to the MQTT broker and subscribe to the location topic
  Future<void> connectToMqtt() async {
    if (_isDisposed || !mounted) {
      log('Widget disposed, skipping connection...');
      return;
    }

    if (isConnecting) {
      log('Connection already in progress, skipping...');
      return;
    }

    if (!mounted) return;
    setState(() {
      isConnecting = true;
      connectionError = null;
    });

    try {
      client.port = 8883;
      client.keepAlivePeriod = 20;
      client.secure = true; // Enable SSL/TLS
      client.onDisconnected = onDisconnected;
      client.onConnected = onConnected;
      client.onSubscribed = onSubscribed;
      client.autoReconnect = false; // We'll handle reconnection manually

      // Create SecurityContext for certificates
      final context = SecurityContext.defaultContext;
      try {
        // Load certificates with better error handling
        final rootCA = await rootBundle.load('assets/certs/AmazonRootCA3.pem');
        context.setTrustedCertificatesBytes(rootCA.buffer.asUint8List());

        final clientCert = await rootBundle.load(
          'assets/certs/certificate.pem.crt',
        );
        context.useCertificateChainBytes(clientCert.buffer.asUint8List());

        final privateKey = await rootBundle.load(
          'assets/certs/private.pem.key',
        );
        context.usePrivateKeyBytes(privateKey.buffer.asUint8List());

        client.securityContext = context;
      } on PlatformException catch (e) {
        log('Error loading certificates: $e');
        if (!mounted || _isDisposed) return;
        setState(() {
          isConnecting = false;
          connectionError =
              'Certificate files not found. Please ensure certificates are in assets/certs/';
        });
        return;
      } catch (e) {
        log('Error loading certificates: $e');
        if (!mounted || _isDisposed) return;
        setState(() {
          isConnecting = false;
          connectionError = 'Failed to load certificates: $e';
        });
        return;
      }

      // Attempt connection with timeout
      try {
        await client.connect().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException('Connection timeout after 10 seconds');
          },
        );
      } on SocketException catch (e) {
        log('SocketException connecting to MQTT: ${e.message}');

        // Retry logic with exponential backoff
        if (retryCount < maxRetries) {
          retryCount++;
          final delay = Duration(
            seconds: 2 * retryCount,
          ); // Exponential backoff
          log(
            'Retrying connection in ${delay.inSeconds} seconds (attempt $retryCount/$maxRetries)...',
          );
          setState(() {
            isConnecting = false;
            connectionError = 'Connection failed: ${e.message}. Retrying...';
          });
          await Future.delayed(delay);
          await connectToMqtt();
        } else {
          log('Max retries reached. Connection failed.');
          setState(() {
            isConnecting = false;
            connectionError =
                'Connection failed: ${e.message}. Max retries reached.';
          });
        }
        return;
      } on TimeoutException catch (e) {
        log('TimeoutException connecting to MQTT: $e');

        // Retry logic
        if (retryCount < maxRetries && !_isDisposed) {
          retryCount++;
          final delay = Duration(seconds: 2 * retryCount);
          log(
            'Retrying connection in ${delay.inSeconds} seconds (attempt $retryCount/$maxRetries)...',
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
        log('HandshakeException connecting to MQTT: $e');
        if (!mounted || _isDisposed) return;
        setState(() {
          isConnecting = false;
          connectionError =
              'SSL/TLS handshake failed. Please verify certificates are valid.';
        });
        return;
      } catch (e) {
        log('Error connecting to MQTT: $e');

        // Retry for other connection errors
        if (retryCount < maxRetries && !_isDisposed) {
          retryCount++;
          final delay = Duration(seconds: 2 * retryCount);
          log(
            'Retrying connection in ${delay.inSeconds} seconds (attempt $retryCount/$maxRetries)...',
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
      if (client.connectionStatus?.state == MqttConnectionState.connected) {
        log('Successfully connected to MQTT broker');
        if (!mounted || _isDisposed) return;
        setState(() {
          isConnecting = false;
          connectionError = null;
          retryCount = 0; // Reset retry count on successful connection
        });

        try {
          client.subscribe(widget.topic, MqttQos.atMostOnce);
          client.updates!.listen(
            (List<MqttReceivedMessage<MqttMessage>> c) {
              final MqttPublishMessage recMess =
                  c[0].payload as MqttPublishMessage;
              final String payload = MqttPublishPayload.bytesToStringAsString(
                recMess.payload.message,
              );
              log(payload);
              updateBusLocation(payload);
            },
            onError: (error) {
              log('Error in MQTT message stream: $error');
            },
            cancelOnError: false,
          );
        } catch (e) {
          log('Error subscribing to topic: $e');
          if (!mounted || _isDisposed) return;
          setState(() {
            connectionError = 'Failed to subscribe to topic: $e';
          });
        }
      } else {
        log('Connection failed: ${client.connectionStatus?.state}');
        if (!mounted || _isDisposed) return;
        setState(() {
          isConnecting = false;
          connectionError = 'Failed to establish connection';
        });
      }
    } catch (e, stackTrace) {
      log('Unexpected error in connectToMqtt: $e');
      log('Stack trace: $stackTrace');
      if (!mounted || _isDisposed) return;
      setState(() {
        isConnecting = false;
        connectionError = 'Unexpected error: $e';
      });
    }
  }

  void onConnected() {
    log('Connected to MQTT broker');
  }

  void onDisconnected() {
    log('Disconnected from MQTT broker');
    // Don't try to reconnect or update state if widget is disposed
    if (_isDisposed || !mounted) {
      return;
    }

    try {
      setState(() {
        isConnecting = false;
        connectionError = 'Disconnected from MQTT broker';
      });
      // Attempt to reconnect if not manually disconnected
      if (retryCount < maxRetries && !_isDisposed) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && !_isDisposed) {
            connectToMqtt();
          }
        });
      }
    } catch (e) {
      // Ignore setState errors if widget is disposed
      log('Error in onDisconnected callback: $e');
    }
  }

  void onSubscribed(String topic) {
    log('Subscribed to topic: $topic');
  }

  void updateBusLocation(String payload) {
    if (_isDisposed || !mounted) {
      return;
    }

    try {
      log("Received payload: $payload");

      List<dynamic> data = jsonDecode(payload);

      if (data.isNotEmpty && data[0] is Map<String, dynamic>) {
        Map<String, dynamic> busData = data[0];

        final double lat = busData['latitude'];
        final double lon = busData['longitude'];

        if (!mounted || _isDisposed) return;
        setState(() {
          lastUpdatedTime = DateFormat(
            'h:mm:ss a',
          ).format(DateTime.parse(busData['time_stamp']));
          busLocation = LatLng(lat, lon);
          busPath.add(busLocation!); // Add new location to the path
          showPolyline = false; // Hide the polyline

          // Move the map only if the checkbox is selected and the map is ready
          if (shouldMoveMap && isMapReady) {
            _mapController.move(busLocation!, _mapController.camera.zoom);
          }
        });
      } else {
        log('Invalid data format');
      }
    } catch (e) {
      log('Error parsing JSON payload: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: 'Bus Tracker'),
      body: busLocation == null && connectionError == null
          ? const Center(
              child:
                  CircularProgressIndicator(), // Show loader if busLocation is null
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
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter:
                        busLocation ?? const LatLng(25.2959397, 55.4576871),
                    initialZoom: 17,
                    onMapReady: () {
                      setState(() {
                        isMapReady = true; // Set flag when map is ready
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          // 'https://{s}.tile.openstreetmap.fr/osmfr/{z}/{x}/{y}.png',
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    ),
                    if (showPolyline) // Only show polyline if the flag is true
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: busPath,
                            strokeWidth: 4.0,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        if (busLocation != null)
                          Marker(
                            width: 60.0,
                            height: 60.0,
                            point: busLocation!,
                            child: Image.asset(
                              "assets/location.png",
                              height: 40,
                              width: 40,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
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
              ],
            ),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;

    // Clear callbacks to prevent them from being called after disposal
    try {
      client.onDisconnected = null;
      client.onConnected = null;
      client.onSubscribed = null;
    } catch (e) {
      log('Error clearing MQTT callbacks: $e');
    }

    // Disconnect the client
    try {
      if (client.connectionStatus?.state == MqttConnectionState.connected ||
          client.connectionStatus?.state == MqttConnectionState.connecting) {
        client.disconnect();
      }
    } catch (e) {
      log('Error disconnecting MQTT client: $e');
    }

    super.dispose();
  }
}
