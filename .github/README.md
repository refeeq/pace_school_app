# Play Store Deployment

Simple GitHub Actions workflow for deploying your Flutter app to Google Play Store.

## 🚀 **One Workflow - Everything You Need**

- ✅ **All 10 flavors** supported
- ✅ **Different signing keys** handled automatically  
- ✅ **Internal track only** (safe testing)
- ✅ **Manual or automatic** deployment
- ✅ **Clean and simple**

## 🔧 **Setup**

### 1. Required Secrets

Add these secrets in GitHub → Settings → Secrets:

#### For PACE flavors (pace, iiss, cbsa, dpsa, pmbs, pcbs, pbss, sisd, demo):
```
PACE_STORE_PASSWORD=pace1234
PACE_KEY_PASSWORD=pace1234
PACE_KEYSTORE_BASE64=base64_encoded_pace_key.jks
```

#### For GAES flavor:
```
GAES_STORE_PASSWORD=123456
GAES_KEY_PASSWORD=123456
GAES_KEYSTORE_BASE64=base64_encoded_gaes.key
```

#### Global:
```
GOOGLE_PLAY_SERVICE_ACCOUNT_JSON=your_service_account_json
```

### 2. Convert Keystore to Base64

```bash
# For pace_key.jks (used by most flavors)
base64 -i android/pace_key.jks | pbcopy

# For gaes.key (used by GAES flavor only)
base64 -i path/to/gaes.key | pbcopy
```

## 🎯 **Usage**

### Automatic Deployment
- **Push to main** → Deploys all flavors to internal track
- **Create tag** (v1.0.0) → Deploys all flavors to internal track

### Manual Deployment
1. Go to Actions → "Deploy to Play Store"
2. Click "Run workflow"
3. Choose flavor to deploy
4. Click "Run workflow"

## 📱 **Supported Flavors**

| Flavor | App ID | Key File |
|--------|--------|----------|
| pace | com.pacesharjah.schoolapp | pace_key.jks |
| iiss | com.iiss.schoolapp | pace_key.jks |
| gaes | com.gaes.schoolapp | gaes.key |
| cbsa | com.cbsa.schoolapp | pace_key.jks |
| dpsa | com.dpsa.schoolapp | pace_key.jks |
| pmbs | com.pmbs.schoolapp | pace_key.jks |
| pcbs | com.pcbs.schoolapp | pace_key.jks |
| pbss | com.pbss.schoolapp | pace_key.jks |
| sisd | com.sisd.schoolapp | pace_key.jks |
| demo | com.demo.schoolapp | pace_key.jks |

## 🔒 **Safety**

- All deployments go to **INTERNAL track only**
- No accidental production releases
- Test safely before manual promotion to production

## 🛠️ **Troubleshooting**

- Check workflow logs for detailed error messages
- Verify all secrets are set correctly
- Test build locally first: `flutter build apk --flavor pace`