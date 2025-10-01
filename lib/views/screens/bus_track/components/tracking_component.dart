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
    client.port = 8883;
    client.keepAlivePeriod = 20;
    client.secure = true; // Enable SSL/TLS
    client.onDisconnected = onDisconnected;
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;

    // Create SecurityContext for certificates
    final context = SecurityContext.defaultContext;
    try {
      final rootCA = await rootBundle.load('assets/certs/AmazonRootCA3.pem');
      context.setTrustedCertificatesBytes(rootCA.buffer.asUint8List());

      final clientCert = await rootBundle.load(
        'assets/certs/certificate.pem.crt',
      );
      context.useCertificateChainBytes(clientCert.buffer.asUint8List());

      final privateKey = await rootBundle.load('assets/certs/private.pem.key');
      context.usePrivateKeyBytes(privateKey.buffer.asUint8List());

      client.securityContext = context;
      await client.connect();
    } catch (e) {
      log('Error connecting to MQTT: $e');
      client.disconnect();
      return;
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      client.subscribe(widget.topic, MqttQos.atMostOnce);
      client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
        final String payload = MqttPublishPayload.bytesToStringAsString(
          recMess.payload.message,
        );
        log(payload);
        updateBusLocation(payload);
      });
    }
  }

  void onConnected() {
    log('Connected to MQTT broker');
  }

  void onDisconnected() {
    log('Disconnected from MQTT broker');
  }

  void onSubscribed(String topic) {
    log('Subscribed to topic: $topic');
  }

  void updateBusLocation(String payload) {
    try {
      log("Received payload: $payload");

      List<dynamic> data = jsonDecode(payload);

      if (data.isNotEmpty && data[0] is Map<String, dynamic>) {
        Map<String, dynamic> busData = data[0];

        final double lat = busData['latitude'];
        final double lon = busData['longitude'];

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
      body: busLocation == null
          ? const Center(
              child:
                  CircularProgressIndicator(), // Show loader if busLocation is null
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
                          'https://{s}.tile.openstreetmap.fr/osmfr/{z}/{x}/{y}.png',
                      // 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
    client.disconnect();
    super.dispose();
  }
}
