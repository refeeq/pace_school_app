# Certificate Analysis - School App MQTT Certificates

## 📋 Certificate Status

### ✅ Certificates Found in Build Directory

The certificates are present in the build artifacts and are being loaded successfully:

**Location:** `build/app/intermediates/flutter/paceDebug/flutter_assets/assets/certs/`

**Files Found:**
1. ✅ `AmazonRootCA3.pem` - 656 bytes (matches log: 656 bytes)
2. ✅ `certificate.pem.crt` - 1224 bytes (matches log: 1224 bytes)  
3. ✅ `private.pem.key` - 1679 bytes (matches log: 1679 bytes)
4. ✅ `root-ca.pem` - 1187 bytes (additional file)

### ⚠️ Source Directory Status

**Location:** `assets/certs/` - **EMPTY**

The source directory is empty, but certificates are being bundled from somewhere during the build process.

## 🔍 Certificate Loading Verification

From the logs, we can confirm:
- ✅ Root CA loaded successfully (656 bytes)
- ✅ Client certificate loaded successfully (1224 bytes)
- ✅ Private key loaded successfully (1679 bytes)
- ✅ All certificates configured
- ✅ Connection established successfully
- ✅ SSL/TLS handshake successful

## 🎯 Key Finding

**The certificates are working correctly!** The connection is successful, which means:
- Certificates are valid
- SSL/TLS handshake succeeds
- Authentication to AWS IoT Core works
- The issue is **NOT** with the certificates

## 🔴 Real Issue: AWS IoT Core Policy

Since:
- ✅ Connection works
- ✅ Subscription is confirmed
- ❌ No messages received

**The problem is AWS IoT Core Policy Permissions**, specifically missing `iot:Receive` permission.

## 📝 Certificate Details

### File Sizes (from build directory)
```
AmazonRootCA3.pem:     656 bytes
certificate.pem.crt:   1224 bytes
private.pem.key:      1679 bytes
root-ca.pem:          1187 bytes (not used in code)
```

### Certificate Usage in Code

**File:** `lib/views/screens/bus_track/components/tracking_component.dart`

```dart
// Root CA
final rootCA = await rootBundle.load('assets/certs/AmazonRootCA3.pem');

// Client Certificate
final clientCert = await rootBundle.load('assets/certs/certificate.pem.crt');

// Private Key
final privateKey = await rootBundle.load('assets/certs/private.pem.key');
```

## 🔐 Certificate Verification Steps

To verify which certificate is being used:

1. **Check AWS IoT Core Console:**
   - Go to Security → Certificates
   - Find the certificate that matches the one in your app
   - Check the certificate's Common Name (CN) or Subject
   - Verify it's attached to the correct policy

2. **Compare with Transporter App:**
   - The transporter app uses a different certificate
   - Both certificates need proper policies
   - School app needs: `iot:Connect`, `iot:Subscribe`, `iot:Receive`
   - Transporter app needs: `iot:Connect`, `iot:Publish`

## ⚠️ Important Notes

1. **Certificates are NOT the problem** - They're loading and authenticating correctly
2. **Policy permissions ARE the problem** - Missing `iot:Receive` permission
3. **Source directory empty** - Certificates might be:
   - Copied during build from another location
   - In a different source directory (check `android/certs/` if it exists)
   - Managed by a build script

## 🛠️ Next Steps

1. **Fix AWS IoT Core Policy** (see `AWS_IOT_POLICY_FIX.md`)
   - Add `iot:Receive` permission to school app certificate policy
   - Verify resource ARNs are correct

2. **Verify Certificate Identity** (optional):
   - Check which certificate is actually being used
   - Ensure it's the school app certificate (not transporter)
   - Verify it has the correct policy attached

3. **Test After Policy Fix:**
   - No app restart needed
   - Messages should start flowing immediately
   - Check logs for `📨 [MQTT] Raw message batch received`

## 📊 Summary

| Component | Status | Notes |
|-----------|--------|-------|
| Certificates Present | ✅ | Found in build directory |
| Certificate Loading | ✅ | All 3 files load successfully |
| SSL/TLS Handshake | ✅ | Connection established |
| Authentication | ✅ | AWS IoT Core accepts connection |
| Subscription | ✅ | Topic subscription confirmed |
| Message Reception | ❌ | **Policy issue - missing iot:Receive** |

## 🔗 Related Documents

- `AWS_IOT_POLICY_FIX.md` - How to fix the policy issue
- `MQTT_TROUBLESHOOTING.md` - General troubleshooting guide
- `MQTT_CONFIGURATION.md` - MQTT setup documentation

