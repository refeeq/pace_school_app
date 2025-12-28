# MQTT Configuration Guide

This document explains the MQTT (Message Queuing Telemetry Transport) configuration used in this project for real-time bus tracking functionality.

## Table of Contents

- [Overview](#overview)
- [MQTT Broker Details](#mqtt-broker-details)
- [Certificate Configuration](#certificate-configuration)
- [Connection Setup](#connection-setup)
- [Implementation Details](#implementation-details)
- [Certificate Management](#certificate-management)
- [Troubleshooting](#troubleshooting)

---

## Overview

The application uses MQTT to receive real-time bus location updates from AWS IoT Core. The MQTT client connects securely using SSL/TLS certificates for authentication and encryption.

**Key Features:**
- Secure MQTT connection to AWS IoT Core
- Real-time bus location tracking
- Certificate-based authentication
- Automatic reconnection handling

**Package Used:** `mqtt_client: ^10.11.1`

---

## MQTT Broker Details

### AWS IoT Core Endpoint

**Broker URL:** `a7nalq3sp79e9-ats.iot.ap-south-1.amazonaws.com`  
**Port:** `8883` (SSL/TLS)  
**Region:** `ap-south-1` (Asia Pacific - Mumbai)

### Connection Parameters

- **Protocol:** MQTT over SSL/TLS
- **Keep Alive Period:** 20 seconds
- **QoS Level:** At Most Once (0)
- **Client ID Format:** `mqtt_<timestamp>_<random_number>`

**Example Client ID:** `mqtt_1704067200000_456`

---

## Certificate Configuration

### ⚠️ CRITICAL: Certificate File Locations

**Source Location (Development/Storage):**
- Certificates are stored in: `android/certs/` directory
- This is where you place the certificate files before deployment

**Runtime Location (Assets):**
- Certificates are loaded from: `assets/certs/` directory
- These files are bundled with the app during build

**Required Certificate Files:**

1. **Root CA Certificate**
   - **File:** `AmazonRootCA3.pem`
   - **Purpose:** Trust anchor for AWS IoT Core
   - **Location:** `assets/certs/AmazonRootCA3.pem`
   - **Source:** Download from [AWS IoT Core Root CA](https://www.amazontrust.com/repository/)

2. **Client Certificate**
   - **File:** `certificate.pem.crt`
   - **Purpose:** Device certificate for authentication
   - **Location:** `assets/certs/certificate.pem.crt`
   - **Source:** Generated from AWS IoT Core Console

3. **Private Key**
   - **File:** `private.pem.key`
   - **Purpose:** Private key for certificate authentication
   - **Location:** `assets/certs/private.pem.key`
   - **Source:** Generated from AWS IoT Core Console

### Certificate File Structure

```
project-root/
├── android/
│   └── certs/                    # Source location (development)
│       ├── AmazonRootCA3.pem
│       ├── certificate.pem.crt
│       └── private.pem.key
├── assets/
│   └── certs/                    # Runtime location (bundled with app)
│       ├── AmazonRootCA3.pem
│       ├── certificate.pem.crt
│       └── private.pem.key
└── pubspec.yaml                  # Assets configuration
```

### Assets Configuration

**Location:** `pubspec.yaml`

The certificates must be declared in the assets section:

```yaml
flutter:
  assets:
    - assets/certs/
```

This ensures all certificate files in the `assets/certs/` directory are bundled with the app.

---

## Connection Setup

### Implementation Location

**File:** `lib/views/screens/bus_track/components/tracking_component.dart`

### Connection Flow

1. **Initialize MQTT Client**
   ```dart
   client = MqttServerClient(
     'a7nalq3sp79e9-ats.iot.ap-south-1.amazonaws.com',
     clientId,
   );
   ```

2. **Configure Connection**
   ```dart
   client.port = 8883;
   client.keepAlivePeriod = 20;
   client.secure = true; // Enable SSL/TLS
   ```

3. **Load Certificates**
   ```dart
   final context = SecurityContext.defaultContext;
   
   // Load Root CA
   final rootCA = await rootBundle.load('assets/certs/AmazonRootCA3.pem');
   context.setTrustedCertificatesBytes(rootCA.buffer.asUint8List());
   
   // Load Client Certificate
   final clientCert = await rootBundle.load('assets/certs/certificate.pem.crt');
   context.useCertificateChainBytes(clientCert.buffer.asUint8List());
   
   // Load Private Key
   final privateKey = await rootBundle.load('assets/certs/private.pem.key');
   context.usePrivateKeyBytes(privateKey.buffer.asUint8List());
   
   client.securityContext = context;
   ```

4. **Connect and Subscribe**
   ```dart
   await client.connect();
   client.subscribe(topic, MqttQos.atMostOnce);
   ```

### Complete Connection Code

```dart
Future<void> connectToMqtt() async {
  client.port = 8883;
  client.keepAlivePeriod = 20;
  client.secure = true;
  client.onDisconnected = onDisconnected;
  client.onConnected = onConnected;
  client.onSubscribed = onSubscribed;

  // Create SecurityContext for certificates
  final context = SecurityContext.defaultContext;
  try {
    // Load Root CA
    final rootCA = await rootBundle.load('assets/certs/AmazonRootCA3.pem');
    context.setTrustedCertificatesBytes(rootCA.buffer.asUint8List());

    // Load Client Certificate
    final clientCert = await rootBundle.load('assets/certs/certificate.pem.crt');
    context.useCertificateChainBytes(clientCert.buffer.asUint8List());

    // Load Private Key
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
      updateBusLocation(payload);
    });
  }
}
```

---

## Implementation Details

### MQTT Client Initialization

**Component:** `TrackingComponent`

```dart
class TrackingComponentState extends State<TrackingComponent> {
  String clientId = 'mqtt_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(1000)}';
  late MqttServerClient client;
  
  @override
  void initState() {
    super.initState();
    client = MqttServerClient(
      'a7nalq3sp79e9-ats.iot.ap-south-1.amazonaws.com',
      clientId,
    );
    connectToMqtt();
  }
}
```

### Message Handling

**Topic Subscription:**
- Topics are passed as a parameter to `TrackingComponent`
- Format: Dynamic topic based on bus/route identifier
- Example: `bus/track/route123`

**Message Processing:**
```dart
client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
  final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
  final String payload = MqttPublishPayload.bytesToStringAsString(
    recMess.payload.message,
  );
  updateBusLocation(payload);
});
```

**Payload Format:**
- JSON string containing bus location data
- Typically includes: latitude, longitude, timestamp, bus ID

### Connection Callbacks

```dart
void onConnected() {
  log('Connected to MQTT broker');
}

void onDisconnected() {
  log('Disconnected from MQTT broker');
}

void onSubscribed(String topic) {
  log('##Subscribed to topic: $topic');
}
```

---

## Certificate Management

### Obtaining Certificates from AWS IoT Core

1. **Log in to AWS IoT Core Console**
   - Navigate to: AWS Console → IoT Core → Security → Certificates

2. **Create/Download Certificates**
   - Create a new certificate or use existing one
   - Download the following files:
     - Device certificate (`.pem.crt`)
     - Private key (`.pem.key`)

3. **Download Root CA**
   - Download `Amazon Root CA 3` from [AWS Trust Services](https://www.amazontrust.com/repository/)
   - Save as `AmazonRootCA3.pem`

### Setting Up Certificates in Project

**Step 1: Place Certificates in Source Location**
```bash
# Copy certificates to android/certs directory
cp certificate.pem.crt android/certs/
cp private.pem.key android/certs/
cp AmazonRootCA3.pem android/certs/
```

**Step 2: Copy to Assets Directory**
```bash
# Copy certificates to assets/certs directory
cp android/certs/* assets/certs/
```

**Step 3: Verify pubspec.yaml**
Ensure `assets/certs/` is included in the assets section:
```yaml
flutter:
  assets:
    - assets/certs/
```

**Step 4: Clean and Rebuild**
```bash
flutter clean
flutter pub get
flutter run
```

### Certificate Security Best Practices

⚠️ **IMPORTANT SECURITY NOTES:**

1. **Never Commit Certificates to Version Control**
   - Add to `.gitignore`:
     ```
     android/certs/
     assets/certs/*.pem
     assets/certs/*.crt
     assets/certs/*.key
     ```

2. **Use Environment-Specific Certificates**
   - Development certificates for testing
   - Production certificates for release builds
   - Consider using different certificate sets per environment

3. **Certificate Rotation**
   - Regularly rotate certificates for security
   - Update certificates in both `android/certs/` and `assets/certs/`

4. **Access Control**
   - Limit access to certificate files
   - Use secure storage for certificate files
   - Implement proper IAM policies in AWS IoT Core

### Certificate File Permissions

**Linux/macOS:**
```bash
# Set appropriate permissions
chmod 600 android/certs/*.key
chmod 644 android/certs/*.pem
chmod 644 android/certs/*.crt
```

---

## Troubleshooting

### Connection Issues

**Problem:** "Error connecting to MQTT"
- **Solution:**
  - Verify certificates exist in `assets/certs/` directory
  - Check certificate file names match exactly (case-sensitive)
  - Ensure certificates are not expired
  - Verify AWS IoT Core endpoint is correct
  - Check internet connectivity

**Problem:** "Certificate not found" error
- **Solution:**
  - Verify files exist in `assets/certs/`:
    - `AmazonRootCA3.pem`
    - `certificate.pem.crt`
    - `private.pem.key`
  - Check `pubspec.yaml` includes `assets/certs/`
  - Run `flutter clean && flutter pub get`
  - Rebuild the app

**Problem:** "SSL/TLS handshake failed"
- **Solution:**
  - Verify Root CA certificate is correct (Amazon Root CA 3)
  - Check client certificate matches the device registered in AWS IoT Core
  - Ensure private key matches the certificate
  - Verify certificate is activated in AWS IoT Core

**Problem:** "Connection timeout"
- **Solution:**
  - Check network connectivity
  - Verify AWS IoT Core endpoint is accessible
  - Check firewall/security group settings
  - Verify port 8883 is not blocked

### Certificate Issues

**Problem:** Certificates not loading
- **Solution:**
  - Verify file paths are correct: `assets/certs/<filename>`
  - Check file extensions match exactly
  - Ensure files are not corrupted
  - Verify files are included in app bundle (check build output)

**Problem:** "Invalid certificate format"
- **Solution:**
  - Ensure certificates are in PEM format
  - Check file encoding (should be UTF-8)
  - Verify certificate structure (BEGIN/END markers)
  - Re-download certificates from AWS IoT Core

**Problem:** Certificate expired
- **Solution:**
  - Generate new certificates from AWS IoT Core
  - Update certificate files in both `android/certs/` and `assets/certs/`
  - Rebuild and redeploy the app

### Topic Subscription Issues

**Problem:** Not receiving messages
- **Solution:**
  - Verify topic name is correct
  - Check subscription was successful (check logs)
  - Verify device has publish permissions for the topic
  - Check AWS IoT Core policy allows subscription

**Problem:** "Subscription failed"
- **Solution:**
  - Verify topic exists
  - Check IAM/IoT policy permissions
  - Ensure client is connected before subscribing
  - Verify QoS level is supported

### General Issues

**Problem:** App crashes on MQTT connection
- **Solution:**
  - Check error logs for specific error message
  - Verify all certificate files are present
  - Ensure SecurityContext is properly initialized
  - Check for null pointer exceptions

**Problem:** High battery drain
- **Solution:**
  - Adjust `keepAlivePeriod` if needed
  - Implement connection pooling
  - Disconnect when not actively tracking
  - Use appropriate QoS levels

---

## AWS IoT Core Policy Example

To allow MQTT connections, your AWS IoT Core policy should include:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iot:Connect"
      ],
      "Resource": "arn:aws:iot:ap-south-1:*:client/mqtt_*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iot:Subscribe"
      ],
      "Resource": "arn:aws:iot:ap-south-1:*:topicfilter/bus/track/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iot:Receive"
      ],
      "Resource": "arn:aws:iot:ap-south-1:*:topic/bus/track/*"
    }
  ]
}
```

---

## Additional Resources

- [AWS IoT Core Documentation](https://docs.aws.amazon.com/iot/)
- [MQTT Client Package](https://pub.dev/packages/mqtt_client)
- [AWS IoT Core Security Best Practices](https://docs.aws.amazon.com/iot/latest/developerguide/security-best-practices.html)
- [Certificate Management in AWS IoT](https://docs.aws.amazon.com/iot/latest/developerguide/x509-client-certs.html)

---

## Quick Reference

### Certificate File Locations
- **Source:** `android/certs/`
- **Runtime:** `assets/certs/`
- **Required Files:**
  - `AmazonRootCA3.pem`
  - `certificate.pem.crt`
  - `private.pem.key`

### MQTT Connection Details
- **Endpoint:** `a7nalq3sp79e9-ats.iot.ap-south-1.amazonaws.com`
- **Port:** `8883`
- **Protocol:** SSL/TLS
- **Keep Alive:** 20 seconds

### Common Commands
```bash
# Copy certificates from source to assets
cp android/certs/* assets/certs/

# Clean and rebuild
flutter clean && flutter pub get && flutter run

# Verify certificates exist
ls -la assets/certs/
```

---

**Last Updated:** January 2025  
**Maintained By:** Development Team

