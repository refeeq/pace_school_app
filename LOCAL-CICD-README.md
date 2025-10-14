# 🚀 Local CI/CD Pipeline for School App

Complete CI/CD solution running on your self-hosted machine, bypassing GitHub's storage quotas and billing limits.

## 📋 Overview

This local CI/CD setup provides:
- **Full automation** on your machine
- **No GitHub billing** - completely free
- **All 9 flavors** built automatically
- **Local artifact storage** - no quotas
- **Scheduled builds** - cron job support
- **Complete control** - your infrastructure

## 🛠️ Scripts Available

### 1. `local-cicd.sh` - Full CI/CD Pipeline
Complete pipeline with all features:
- ✅ Prerequisites checking
- ✅ Environment setup
- ✅ Code analysis and testing
- ✅ All 9 flavors build
- ✅ Local artifact storage
- ✅ Build summaries and logging

**Usage:**
```bash
./local-cicd.sh
```

### 2. `quick-build.sh` - Quick Build
Fast build for specific flavors:
- ⚡ Quick builds
- 🎯 Specific flavors only
- 📁 Simple artifact storage

**Usage:**
```bash
# Build specific flavors
./quick-build.sh pace gaes cbsa

# Build single flavor
./quick-build.sh pace
```

### 3. `setup-cron.sh` - Automated Scheduling
Set up automated builds with cron:
- 🕐 Scheduled builds
- 📅 Flexible timing
- 📝 Automatic logging

**Usage:**
```bash
./setup-cron.sh
```

## 🚀 Quick Start

### 1. Run Full CI/CD Pipeline
```bash
# Make scripts executable
chmod +x *.sh

# Run complete pipeline
./local-cicd.sh
```

### 2. Quick Build Specific Flavors
```bash
# Build pace, gaes, and cbsa
./quick-build.sh pace gaes cbsa

# Build only pace
./quick-build.sh pace
```

### 3. Setup Automated Builds
```bash
# Setup cron job for daily builds at 2 AM
./setup-cron.sh
# Enter: 0 2 * * *
# Choose: 1 (full CI/CD)
```

## 📁 File Structure

After running, you'll have:
```
school_app/
├── local-cicd.sh          # Full CI/CD pipeline
├── quick-build.sh         # Quick build script
├── setup-cron.sh          # Cron job setup
├── build-artifacts/       # Build outputs
│   └── 20241201_143022/   # Timestamped builds
│       ├── pace-release.aab
│       ├── gaes-release.aab
│       └── build_summary.txt
├── builds/                # Quick build outputs
│   └── 20241201/          # Date-based builds
│       └── pace-release.aab
└── logs/                  # Build logs
    ├── cicd_20241201_143022.log
    └── cron.log
```

## ⚙️ Configuration

### Environment Variables
Set these in your shell profile (`~/.zshrc` or `~/.bash_profile`):
```bash
export ANDROID_HOME=$HOME/Library/Android/sdk
export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools
```

### Signing Configuration
The scripts expect these environment variables for signing:
```bash
# For PACE flavors (pace, cbsa, dpsa, iiss, pbss, pcbs, pmbs, sisd)
export PACE_STORE_PASSWORD="your_password"
export PACE_KEY_PASSWORD="your_password"

# For GAES flavor
export GAES_STORE_PASSWORD="your_password"
export GAES_KEY_PASSWORD="your_password"
```

## 📊 Build Flavors

| Flavor | Package Name | App Name | Key File |
|--------|-------------|----------|----------|
| **pace** | com.pacesharjah.schoolapp | PACE INTL | pace_key.jks |
| **gaes** | com.gaes.schoolapp | GAES | gaes.key |
| **cbsa** | com.cbsa.schoolapp | CBSA | pace_key.jks |
| **dpsa** | com.dpsa.schoolapp | DPSA | pace_key.jks |
| **iiss** | com.iiss.schoolapp | IISS | pace_key.jks |
| **pbss** | com.pbss.schoolapp | PBSS | pace_key.jks |
| **pcbs** | com.pcbs.schoolapp | PCBS | pace_key.jks |
| **pmbs** | com.pmbs.schoolapp | PMBS | pace_key.jks |
| **sisd** | com.sisd.schoolapp | SISD | pace_key.jks |

## 🔧 Cron Job Examples

### Daily Build at 2 AM
```bash
0 2 * * * cd /path/to/school_app && ./local-cicd.sh >> logs/cron.log 2>&1
```

### Every 6 Hours
```bash
0 */6 * * * cd /path/to/school_app && ./quick-build.sh pace gaes cbsa >> logs/cron.log 2>&1
```

### Weekdays at 9 AM
```bash
0 9 * * 1-5 cd /path/to/school_app && ./local-cicd.sh >> logs/cron.log 2>&1
```

## 📈 Benefits

| Feature | GitHub Actions | Local CI/CD |
|---------|----------------|-------------|
| **Cost** | $0.008/minute | Free |
| **Storage** | 500MB limit | Unlimited |
| **Speed** | Standard | Faster (your hardware) |
| **Control** | Limited | Complete |
| **Privacy** | GitHub servers | Your machine |
| **Customization** | Limited | Full control |

## 🐛 Troubleshooting

### Common Issues

1. **Flutter not found**
   ```bash
   # Install Flutter
   brew install --cask flutter
   # Or download from https://flutter.dev
   ```

2. **Android SDK not found**
   ```bash
   # Install Android Studio or SDK
   brew install --cask android-commandlinetools
   # Set ANDROID_HOME
   export ANDROID_HOME=$HOME/Library/Android/sdk
   ```

3. **Signing issues**
   ```bash
   # Ensure keystore files exist
   ls -la android/pace_key.jks
   ls -la android/gaes.key
   # Set environment variables
   export PACE_STORE_PASSWORD="your_password"
   ```

4. **Permission denied**
   ```bash
   # Make scripts executable
   chmod +x *.sh
   ```

## 📞 Support

If you encounter issues:
1. Check the log files in `logs/`
2. Verify environment variables
3. Ensure all prerequisites are installed
4. Check file permissions

## 🎉 Success!

Once set up, you'll have:
- ✅ Complete CI/CD on your machine
- ✅ No GitHub billing or quotas
- ✅ All 9 flavors building automatically
- ✅ Local artifact storage
- ✅ Scheduled builds
- ✅ Full control and customization

Happy building! 🚀
