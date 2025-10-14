# School App - Auto-Deploy System

A Flutter application with automated CI/CD pipeline that builds and deploys to Google Play Store.

## 🚀 Features

- **9 School Flavors**: pace, gaes, cbsa, dpsa, iiss, pbss, pcbs, pmbs, sisd
- **Auto-Deploy**: Push to GitHub → Automatic build → Deploy to Play Store
- **Self-Hosted Runner**: Uses your AWS Mac machine for building
- **Play Store Integration**: Direct upload to Google Play Console
- **Notifications**: Real-time build status alerts

## 📋 Quick Start

### 1. Setup AWS Mac Machine
```bash
# SSH into your AWS Mac
ssh ec2-user@your-aws-mac-ip

# Clone repository
git clone https://github.com/hashiqvh/school_app.git
cd school_app

# Run setup
./setup-aws-mac.sh
```

### 2. Add GitHub Secrets
Go to GitHub → Settings → Secrets and variables → Actions

Add these secrets:
- `PACE_STORE_PASSWORD` - Password for pace_key.jks
- `PACE_KEY_PASSWORD` - Key password for pace_key.jks
- `PACE_KEYSTORE_BASE64` - Base64 encoded pace_key.jks file
- `GAES_STORE_PASSWORD` - Password for gaes.key
- `GAES_KEY_PASSWORD` - Key password for gaes.key
- `GAES_KEYSTORE_BASE64` - Base64 encoded gaes.key file
- `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` - Google Play Console service account JSON

### 3. Deploy
```bash
# Make changes and push
git add .
git commit -m "Your changes"
git push origin main

# Watch the magic happen! ✨
```

## 🔧 How It Works

1. **Push to GitHub** → Triggers `auto-deploy-playstore.yml` workflow
2. **AWS Mac activates** → Self-hosted runner starts
3. **Pulls latest code** → Builds all 9 flavors
4. **Uploads to Play Store** → Internal track by default
5. **Sends notifications** → Success/failure alerts
6. **Stores artifacts** → AABs saved locally

## 📊 Monitoring

### Check Deployment Status
```bash
# On AWS Mac
./monitor-deployments.sh
```

### View Logs
```bash
# Build logs
tail -f logs/git-hooks.log

# Notification logs
tail -f logs/notifications.log
```

### Manual Deployment
- Go to GitHub Actions tab
- Click "Auto Deploy to Play Store"
- Click "Run workflow"
- Choose track (internal/alpha/beta/production)

## 🗂️ Project Structure

```
school_app/
├── .github/workflows/
│   └── auto-deploy-playstore.yml    # Main deployment workflow
├── android/                          # Android configuration
├── lib/                             # Flutter source code
│   └── schools/                     # School-specific code
├── assets/                          # App assets and icons
├── setup-aws-mac.sh                 # AWS Mac setup script
├── quick-build.sh                   # Quick build script
├── setup-git-hooks.sh               # Git hooks for auto-pull
├── notify-deployment.sh             # Notification system
└── monitor-deployments.sh           # Deployment monitoring
```

## 🎯 Flavors

| Flavor | Description | Signing Key |
|--------|-------------|-------------|
| pace | PACE School | pace_key.jks |
| gaes | GAES School | gaes.key |
| cbsa | CBSA School | pace_key.jks |
| dpsa | DPSA School | pace_key.jks |
| iiss | IISS School | pace_key.jks |
| pbss | PBSS School | pace_key.jks |
| pcbs | PCBS School | pace_key.jks |
| pmbs | PMBS School | pace_key.jks |
| sisd | SISD School | pace_key.jks |

## 🔑 Required Secrets

### Keystore Files
- `pace_key.jks` - Main signing key for most flavors
- `gaes.key` - Special key for GAES flavor

### Base64 Encoding
```bash
# Convert keystore to base64
base64 -i pace_key.jks | pbcopy
base64 -i gaes.key | pbcopy
```

### Google Play Console
1. Go to Google Play Console
2. Setup → API access
3. Create service account
4. Download JSON key file
5. Add content as `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`

## 🚨 Troubleshooting

### Build Fails
- Check GitHub Actions logs
- Verify secrets are correct
- Check AWS Mac logs: `tail -f logs/git-hooks.log`

### Notifications Not Working
```bash
# Setup notifications
./notify-deployment.sh --setup
```

### Environment Issues
```bash
# Check environment
echo $ANDROID_HOME
echo $ANDROID_SDK_ROOT
which flutter
```

## 📱 Play Store Tracks

- **Internal**: Testing within organization
- **Alpha**: Limited testing
- **Beta**: Open testing
- **Production**: Public release

## 🎉 Success!

Your auto-deploy system is now ready! Just push code to GitHub and watch it automatically build and deploy to Play Store! 🚀