import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/views/components/common_app_bar.dart';

class MqttTestPage extends StatefulWidget {
  const MqttTestPage({super.key});

  @override
  State<MqttTestPage> createState() => _MqttTestPageState();
}

class _MqttTestPageState extends State<MqttTestPage> {
  // MQTT Client
  MqttServerClient? client;

  // Connection state
  bool isConnected = false;
  bool isConnecting = false;
  String connectionStatus = 'Disconnected';
  String? connectionError;

  // Broker configuration
  final TextEditingController brokerController = TextEditingController(
    text: 'test.mosquitto.org',
  );
  final TextEditingController portController = TextEditingController(
    text: '1883',
  );
  final TextEditingController clientIdController = TextEditingController(
    text: 'Mqtt_TestClient_${DateTime.now().millisecondsSinceEpoch}',
  );

  // Subscription
  final TextEditingController subscribeTopicController = TextEditingController(
    text: 'test/lol',
  );
  final List<String> subscribedTopics = [];
  final List<Map<String, String>> receivedMessages = [];

  // Publishing
  final TextEditingController publishTopicController = TextEditingController(
    text: 'Dart/Mqtt_client/testtopic',
  );
  final TextEditingController publishMessageController = TextEditingController(
    text: 'Hello from mqtt_client test page',
  );

  // Statistics
  int pongCount = 0;
  int pingCount = 0;
  String? lastCycleLatency;
  String? averageCycleLatency;

  // Stream subscription
  StreamSubscription<List<MqttReceivedMessage<MqttMessage?>>>?
  _updatesSubscription;

  @override
  void dispose() {
    _disconnect();
    brokerController.dispose();
    portController.dispose();
    clientIdController.dispose();
    subscribeTopicController.dispose();
    publishTopicController.dispose();
    publishMessageController.dispose();
    _updatesSubscription?.cancel();
    super.dispose();
  }

  Future<void> _connect() async {
    if (isConnecting || isConnected) {
      _showSnackBar('Already connected or connecting');
      return;
    }

    setState(() {
      isConnecting = true;
      connectionStatus = 'Connecting...';
      connectionError = null;
    });

    try {
      // Create client
      final broker = brokerController.text.trim();
      final port = int.tryParse(portController.text.trim()) ?? 1883;
      final clientId = clientIdController.text.trim().isEmpty
          ? 'Mqtt_TestClient_${DateTime.now().millisecondsSinceEpoch}'
          : clientIdController.text.trim();

      client = MqttServerClient(broker, clientId);
      client!.port = port;

      // Configure client
      client!.logging(on: true);
      client!.setProtocolV311();
      client!.keepAlivePeriod = 20;
      client!.connectTimeoutPeriod = 2000;

      // Set callbacks
      client!.onDisconnected = _onDisconnected;
      client!.onConnected = _onConnected;
      client!.onSubscribed = _onSubscribed;
      client!.pongCallback = _pong;
      client!.pingCallback = _ping;

      // Connection message
      final connMess = MqttConnectMessage()
          .withClientIdentifier(clientId)
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);

      client!.connectionMessage = connMess;

      log('MQTT Test: Connecting to $broker:$port...');

      // Connect
      await client!.connect();

      // Check connection status
      if (client!.connectionStatus!.state == MqttConnectionState.connected) {
        setState(() {
          isConnected = true;
          isConnecting = false;
          connectionStatus = 'Connected';
        });

        // Listen for messages
        _updatesSubscription = client!.updates!.listen(
          (List<MqttReceivedMessage<MqttMessage?>>? c) {
            if (c == null || c.isEmpty) return;

            final recMess = c[0].payload as MqttPublishMessage;
            final pt = MqttPublishPayload.bytesToStringAsString(
              recMess.payload.message,
            );

            setState(() {
              receivedMessages.insert(0, {
                'topic': c[0].topic,
                'message': pt,
                'timestamp': DateTime.now().toString().substring(11, 19),
              });
              // Keep only last 50 messages
              if (receivedMessages.length > 50) {
                receivedMessages.removeLast();
              }
            });

            log('MQTT Test: Received message on topic ${c[0].topic}: $pt');
          },
          onError: (error) {
            log('MQTT Test: Error in message stream: $error');
            _showSnackBar('Error receiving message: $error');
          },
        );

        _showSnackBar('Connected successfully');
      } else {
        throw Exception(
          'Connection failed: ${client!.connectionStatus!.state}',
        );
      }
    } on NoConnectionException catch (e) {
      log('MQTT Test: Connection exception - $e');
      setState(() {
        isConnecting = false;
        connectionStatus = 'Connection Failed';
        connectionError = e.toString();
      });
      _showSnackBar('Connection failed: $e');
      client?.disconnect();
    } on SocketException catch (e) {
      log('MQTT Test: Socket exception - $e');
      setState(() {
        isConnecting = false;
        connectionStatus = 'Connection Failed';
        connectionError = e.toString();
      });
      _showSnackBar('Socket error: $e');
      client?.disconnect();
    } catch (e) {
      log('MQTT Test: Unexpected error - $e');
      setState(() {
        isConnecting = false;
        connectionStatus = 'Connection Failed';
        connectionError = e.toString();
      });
      _showSnackBar('Error: $e');
      client?.disconnect();
    }
  }

  Future<void> _disconnect() async {
    if (!isConnected && !isConnecting) return;

    try {
      _updatesSubscription?.cancel();
      _updatesSubscription = null;

      client?.onDisconnected = null;
      client?.onConnected = null;
      client?.onSubscribed = null;
      // Note: pongCallback and pingCallback cannot be set to null

      if (client != null) {
        client!.disconnect();
      }

      setState(() {
        isConnected = false;
        isConnecting = false;
        connectionStatus = 'Disconnected';
        subscribedTopics.clear();
        pongCount = 0;
        pingCount = 0;
        lastCycleLatency = null;
        averageCycleLatency = null;
      });

      _showSnackBar('Disconnected');
    } catch (e) {
      log('MQTT Test: Error disconnecting - $e');
      setState(() {
        isConnected = false;
        isConnecting = false;
        connectionStatus = 'Disconnected';
      });
    }
  }

  void _subscribe() {
    if (!isConnected || client == null) {
      _showSnackBar('Not connected');
      return;
    }

    final topic = subscribeTopicController.text.trim();
    if (topic.isEmpty) {
      _showSnackBar('Please enter a topic');
      return;
    }

    try {
      client!.subscribe(topic, MqttQos.atMostOnce);
      if (!subscribedTopics.contains(topic)) {
        setState(() {
          subscribedTopics.add(topic);
        });
      }
      _showSnackBar('Subscribed to: $topic');
    } catch (e) {
      log('MQTT Test: Error subscribing - $e');
      _showSnackBar('Error subscribing: $e');
    }
  }

  void _unsubscribe(String topic) {
    if (!isConnected || client == null) {
      _showSnackBar('Not connected');
      return;
    }

    try {
      client!.unsubscribe(topic);
      setState(() {
        subscribedTopics.remove(topic);
      });
      _showSnackBar('Unsubscribed from: $topic');
    } catch (e) {
      log('MQTT Test: Error unsubscribing - $e');
      _showSnackBar('Error unsubscribing: $e');
    }
  }

  void _publish() {
    if (!isConnected || client == null) {
      _showSnackBar('Not connected');
      return;
    }

    final topic = publishTopicController.text.trim();
    final message = publishMessageController.text.trim();

    if (topic.isEmpty) {
      _showSnackBar('Please enter a topic');
      return;
    }

    if (message.isEmpty) {
      _showSnackBar('Please enter a message');
      return;
    }

    try {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);

      client!.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
      _showSnackBar('Published to: $topic');
    } catch (e) {
      log('MQTT Test: Error publishing - $e');
      _showSnackBar('Error publishing: $e');
    }
  }

  void _onConnected() {
    log('MQTT Test: Connected callback');
    if (mounted) {
      setState(() {
        connectionStatus = 'Connected';
      });
    }
  }

  void _onDisconnected() {
    log('MQTT Test: Disconnected callback');
    if (mounted) {
      setState(() {
        isConnected = false;
        isConnecting = false;
        connectionStatus = 'Disconnected';
        subscribedTopics.clear();
      });
    }
  }

  void _onSubscribed(String topic) {
    log('MQTT Test: Subscribed to topic: $topic');
    if (mounted) {
      _showSnackBar('Subscription confirmed: $topic');
    }
  }

  void _pong() {
    log('MQTT Test: Pong received');
    if (mounted && client != null) {
      setState(() {
        pongCount++;
        lastCycleLatency = '${client!.lastCycleLatency?.toStringAsFixed(2)} ms';
        averageCycleLatency =
            '${client!.averageCycleLatency?.toStringAsFixed(2)} ms';
      });
    }
  }

  void _ping() {
    log('MQTT Test: Ping sent');
    if (mounted) {
      setState(() {
        pingCount++;
      });
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
    }
  }

  void _clearMessages() {
    setState(() {
      receivedMessages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: 'MQTT Test Client'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Connection Status Card
            Card(
              color: isConnected
                  ? Colors.green.shade50
                  : isConnecting
                  ? Colors.orange.shade50
                  : Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isConnected
                              ? Icons.check_circle
                              : isConnecting
                              ? Icons.sync
                              : Icons.cancel,
                          color: isConnected
                              ? Colors.green
                              : isConnecting
                              ? Colors.orange
                              : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Status: $connectionStatus',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (connectionError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Error: $connectionError',
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ],
                    if (isConnected && client != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Last Latency: ${lastCycleLatency ?? "N/A"}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        'Average Latency: ${averageCycleLatency ?? "N/A"}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        'Ping: $pingCount | Pong: $pongCount',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Connection Configuration Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Connection Configuration',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: brokerController,
                      decoration: const InputDecoration(
                        labelText: 'Broker',
                        border: OutlineInputBorder(),
                      ),
                      enabled: !isConnected && !isConnecting,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: portController,
                      decoration: const InputDecoration(
                        labelText: 'Port',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      enabled: !isConnected && !isConnecting,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: clientIdController,
                      decoration: const InputDecoration(
                        labelText: 'Client ID',
                        border: OutlineInputBorder(),
                      ),
                      enabled: !isConnected && !isConnecting,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: (isConnected || isConnecting)
                                ? null
                                : _connect,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Connect'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: (isConnected || isConnecting)
                                ? _disconnect
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Disconnect'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Subscribe Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Subscribe to Topic',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: subscribeTopicController,
                      decoration: const InputDecoration(
                        labelText: 'Topic',
                        border: OutlineInputBorder(),
                      ),
                      enabled: isConnected,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: isConnected ? _subscribe : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ConstColors.blueColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Subscribe'),
                    ),
                    if (subscribedTopics.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Subscribed Topics:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...subscribedTopics.map(
                        (topic) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(topic),
                            trailing: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => _unsubscribe(topic),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Publish Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Publish Message',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: publishTopicController,
                      decoration: const InputDecoration(
                        labelText: 'Topic',
                        border: OutlineInputBorder(),
                      ),
                      enabled: isConnected,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: publishMessageController,
                      decoration: const InputDecoration(
                        labelText: 'Message',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      enabled: isConnected,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: isConnected ? _publish : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ConstColors.blueColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Publish'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Received Messages Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Received Messages',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (receivedMessages.isNotEmpty)
                          TextButton(
                            onPressed: _clearMessages,
                            child: const Text('Clear'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (receivedMessages.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text(
                            'No messages received yet',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        height: 300,
                        child: ListView.builder(
                          reverse: true,
                          itemCount: receivedMessages.length,
                          itemBuilder: (context, index) {
                            final msg = receivedMessages[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text(
                                  msg['topic'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(msg['message'] ?? ''),
                                    const SizedBox(height: 4),
                                    Text(
                                      msg['timestamp'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                isThreeLine: true,
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
