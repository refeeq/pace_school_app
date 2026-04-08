# Test Build Workflow

Simple GitHub Actions workflow for testing your Flutter app builds.

## 🚀 **Test Build Workflow**

- ✅ **Pace flavor only** - fast and focused testing
- ✅ **Debug and Release builds** - APK + AAB
- ✅ **Code analysis and tests** - quality checks
- ✅ **Pull request validation** - automatic testing
- ✅ **Clean and simple**

## 🔧 **Setup**

### 1. Required Secrets

Add these secrets in GitHub → Settings → Secrets:

#### For PACE flavor testing:
```
PACE_STORE_PASSWORD=pace1234
PACE_KEY_PASSWORD=pace1234
PACE_KEYSTORE_BASE64=base64_encoded_pace_key.jks
```

### 2. Convert Keystore to Base64

```bash
# For pace_key.jks (used for testing)
base64 -i android/pace_key.jks | pbcopy
```

## 🎯 **Usage**

### Automatic Testing
- **Pull Requests** → Automatically tests pace flavor build
- **Push to main/develop** → No automatic testing (only on PRs)

### Manual Testing

1. Go to Actions tab in your GitHub repository
2. Select "Test Build"
3. Click "Run workflow"
4. **Note**: Only builds pace flavor for testing

### Testing Process

1. **Create PR** → Automatic build testing
2. **Review build** → Check APK/AAB artifacts
3. **Merge PR** → When build is successful
4. **Manual deployment** → Deploy when ready

## 📱 **What Gets Built**

| Build Type | File | Purpose |
|------------|------|---------|
| **Debug APK** | `app-pace-debug.apk` | Development testing |
| **Release APK** | `app-pace-release.apk` | Release testing |
| **Release AAB** | `app-pace-release.aab` | Play Store testing |

## 🔒 **Safety**

- **Test builds only** - no automatic deployment
- **Pace flavor only** - focused testing
- **Artifact retention** - 7 days for download
- **Manual deployment** - when you're ready

## 🛠️ **Troubleshooting**

- Check workflow logs for detailed error messages
- Verify all secrets are set correctly
- Test build locally first: `flutter build apk --flavor pace`
- Check artifacts in GitHub Actions for download links