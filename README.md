# School App - GitHub Actions CI/CD

A Flutter application with automated CI/CD using GitHub Actions.

## 🚀 Features

- **9 School Flavors**: pace, gaes, cbsa, dpsa, iiss, pbss, pcbs, pmbs, sisd
- **Automated Builds**: Push to GitHub → Automatic build → Artifacts uploaded
- **Play Store Deployment**: Manual deployment to Google Play Store
- **GitHub Actions**: Simple, reliable, and free

## 📋 Quick Start

### 1. Build All Flavors
```bash
# Push code to trigger automatic builds
git add .
git commit -m "Your changes"
git push origin main
```

### 2. Deploy to Play Store
1. Go to GitHub Actions tab
2. Click "Deploy to Play Store"
3. Click "Run workflow"
4. Choose track (internal/alpha/beta/production)

## 🔧 How It Works

### **Build Workflow** (`build.yml`)
- **Triggers**: Push to main, Pull requests, Manual
- **Builds**: All 9 flavors in parallel
- **Outputs**: APK and AAB files for each flavor
- **Artifacts**: Stored for 7 days

### **Deploy Workflow** (`deploy.yml`)
- **Triggers**: Manual only
- **Builds**: PACE flavor only
- **Deploys**: To Google Play Store
- **Tracks**: internal/alpha/beta/production

## 🎯 Flavors

| Flavor | Description | Main File |
|--------|-------------|-----------|
| pace | PACE School | lib/schools/pace/pace_main.dart |
| gaes | GAES School | lib/schools/gaes/gaes_main.dart |
| cbsa | CBSA School | lib/schools/cbsa/cbsa_main.dart |
| dpsa | DPSA School | lib/schools/dpsa/dpsa_main.dart |
| iiss | IISS School | lib/schools/iiss/iiss_main.dart |
| pbss | PBSS School | lib/schools/pbss/pbss_main.dart |
| pcbs | PCBS School | lib/schools/pcbs/pcbs_main.dart |
| pmbs | PMBS School | lib/schools/pmbs/pmbs_main.dart |
| sisd | SISD School | lib/schools/sisd/sisd_main.dart |

## 🔑 Required Secrets

For Play Store deployment, add these secrets to your GitHub repository:

1. **PACE_STORE_PASSWORD** - Password for pace_key.jks
2. **PACE_KEY_PASSWORD** - Key password for pace_key.jks
3. **PACE_KEYSTORE_BASE64** - Base64 encoded pace_key.jks file
4. **GOOGLE_PLAY_SERVICE_ACCOUNT_JSON** - Google Play Console service account JSON

### How to Add Secrets:
1. Go to GitHub repository
2. Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. Add each secret with the exact name above

### How to Get Base64 Keystore:
```bash
# Convert keystore to base64
base64 -i android/pace_key.jks | pbcopy
```

## 📊 Monitoring

### Check Build Status:
- Go to GitHub Actions tab
- View build logs and artifacts
- Download APK/AAB files

### View Artifacts:
- Click on any completed workflow
- Scroll down to "Artifacts" section
- Download APK or AAB files

## 🚀 Usage

### Automatic Builds:
```bash
# Make changes and push
echo "// New feature" >> lib/main.dart
git add .
git commit -m "Add new feature"
git push origin main

# Builds will start automatically!
```

### Manual Deployment:
1. Go to Actions tab
2. Click "Deploy to Play Store"
3. Click "Run workflow"
4. Select track and run

## 🎉 Benefits

- ✅ **Simple** - Just push code
- ✅ **Reliable** - GitHub's infrastructure
- ✅ **Free** - 2000 minutes/month for public repos
- ✅ **Fast** - Parallel builds for all flavors
- ✅ **Secure** - Secrets stored safely
- ✅ **Flexible** - Manual deployment control

## 🔧 Troubleshooting

### Build Fails:
- Check GitHub Actions logs
- Verify Flutter version compatibility
- Check for syntax errors

### Deployment Fails:
- Verify all secrets are added correctly
- Check Google Play Console permissions
- Ensure keystore is valid

### No Builds Triggering:
- Check workflow files are in `.github/workflows/`
- Verify branch names match
- Check file syntax

## 📱 Play Store Tracks

- **Internal**: Testing within organization
- **Alpha**: Limited testing
- **Beta**: Open testing
- **Production**: Public release

## 🎊 Success!

Your GitHub Actions CI/CD is now set up! Just push code and watch the magic happen! 🚀# Test auto-deploy Wed Oct 15 08:28:34 +04 2025
# Test auto-deploy Wed Oct 15 08:33:18 +04 2025
# Test auto-deploy Wed Oct 15 08:44:59 +04 2025
