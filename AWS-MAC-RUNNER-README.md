# AWS Mac Runner Setup for Auto-Deploy

This guide explains how to set up and use your AWS Mac instance as a self-hosted GitHub Actions runner for automated deployment of the School App.

## Overview

Your AWS Mac runner will:
- Automatically build all 9 school flavors (pace, gaes, cbsa, dpsa, iiss, pbss, pcbs, pmbs, sisd)
- Upload AAB files to Google Play Store
- Store deployment artifacts locally
- Send notifications about deployment status

## Prerequisites

1. **AWS Mac Instance** with:
   - macOS (latest version recommended)
   - At least 8GB RAM
   - 50GB+ free disk space
   - Internet connection

2. **Required Software** (installed via setup scripts):
   - Flutter SDK
   - Android SDK
   - Java 17+
   - Xcode Command Line Tools

3. **GitHub Repository Access**:
   - Admin access to `hashiqvh/school_app`
   - Ability to add secrets

## Quick Setup

### 1. Initial Setup

```bash
# Clone the repository on your AWS Mac
git clone https://github.com/hashiqvh/school_app.git
cd school_app

# Run the complete setup
chmod +x setup-aws-runner-deploy.sh
./setup-aws-runner-deploy.sh
```

### 2. Configure GitHub Secrets

Add these secrets to your GitHub repository (`Settings > Secrets and variables > Actions`):

#### PACE Credentials (for most flavors)
- `PACE_STORE_PASSWORD`: Your keystore password
- `PACE_KEY_PASSWORD`: Your key password  
- `PACE_KEYSTORE_BASE64`: Base64 encoded keystore file

#### GAES Credentials (for GAES flavor)
- `GAES_STORE_PASSWORD`: GAES keystore password
- `GAES_KEY_PASSWORD`: GAES key password
- `GAES_KEYSTORE_BASE64`: Base64 encoded GAES keystore file

#### Google Play Store
- `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`: Service account JSON for Play Store uploads

### 3. Test the Setup

```bash
# Test the runner environment
./monitor-runner.sh

# Trigger a test workflow
git push origin main
```

## Workflow Details

### Auto-Deploy Workflow

The main workflow (`.github/workflows/auto-deploy-playstore.yml`) will:

1. **Trigger**: On push to `main` branch or manual dispatch
2. **Runner**: Uses your AWS Mac with labels `[self-hosted, macos, aws]`
3. **Matrix Build**: Builds all 9 flavors in parallel
4. **Upload**: Uploads each AAB to Google Play Store
5. **Storage**: Stores AAB files locally in `~/playstore-deployments/`

### Test Workflow

The test workflow (`.github/workflows/test-runner.yml`) will:
- Test the runner environment
- Verify Flutter and Android SDK setup
- Run a test build (PACE flavor only)
- Clean up test artifacts

## Management Commands

### Runner Control
```bash
# Start the runner
./start-runner.sh

# Stop the runner
./stop-runner.sh

# Monitor runner status
./monitor-runner.sh
```

### Build Commands
```bash
# Quick build specific flavors
./quick-build.sh pace gaes cbsa

# Full CI/CD pipeline
./local-cicd.sh

# Test build only
./test-build.sh
```

## File Structure

```
school_app/
├── .github/workflows/
│   ├── auto-deploy-playstore.yml    # Main deployment workflow
│   └── test-runner.yml              # Test workflow
├── setup-aws-runner-deploy.sh       # Complete runner setup
├── setup-aws-mac.sh                 # Environment setup
├── quick-build.sh                   # Quick build script
├── local-cicd.sh                    # Full CI/CD pipeline
├── monitor-runner.sh                # Runner monitoring
└── AWS-MAC-RUNNER-README.md         # This file
```

## Deployment Artifacts

### Local Storage
- **Location**: `~/playstore-deployments/{run_id}/`
- **Files**: `{flavor}-release.aab` for each flavor
- **Summary**: `deployment_summary.txt` with build status

### Play Store Upload
- **Track**: Internal (default), Alpha, Beta, or Production
- **Status**: Completed (ready for review)
- **Priority**: 2 (high priority for updates)

## Monitoring and Troubleshooting

### Check Runner Status
```bash
# View runner logs
tail -f runner.log

# Check system resources
./monitor-runner.sh

# View recent deployments
ls -la ~/playstore-deployments/
```

### Common Issues

1. **Runner Not Starting**
   - Check if `setup-aws-runner-deploy.sh` was run
   - Verify GitHub token is valid
   - Check runner logs: `cat runner.log`

2. **Build Failures**
   - Ensure Flutter and Android SDK are properly installed
   - Check environment variables: `echo $ANDROID_HOME`
   - Run Flutter doctor: `flutter doctor -v`

3. **Upload Failures**
   - Verify Google Play Store credentials
   - Check service account permissions
   - Ensure AAB files are properly signed

4. **Environment Issues**
   - Source environment: `source ~/.zshrc`
   - Re-run setup: `./setup-aws-mac.sh`

### Logs and Debugging

- **Runner Logs**: `runner.log` and `runner.error.log`
- **Build Logs**: GitHub Actions tab in repository
- **Deployment Logs**: `~/playstore-deployments/{run_id}/deployment_summary.txt`

## Security Considerations

1. **Keystore Files**: Never commit keystore files to repository
2. **Secrets**: Use GitHub Secrets for all sensitive data
3. **Runner Access**: Limit runner access to necessary repositories
4. **Cleanup**: Regularly clean up old deployment artifacts

## Maintenance

### Regular Tasks
- Monitor disk space: `df -h`
- Clean old deployments: `rm -rf ~/playstore-deployments/old_runs/`
- Update Flutter: `flutter upgrade`
- Update runner: Re-run setup script

### Updates
- **Flutter**: `flutter upgrade`
- **Android SDK**: Update via Android Studio
- **Runner**: Download latest from GitHub Actions releases

## Support

If you encounter issues:

1. Check the logs first
2. Run the test workflow
3. Verify all secrets are set correctly
4. Ensure the AWS Mac has sufficient resources

## Workflow Triggers

### Automatic Triggers
- **Push to main**: Builds and deploys all flavors
- **Manual dispatch**: Allows selecting Play Store track

### Manual Triggers
- **Test workflow**: Tests runner environment
- **Quick build**: Local testing of specific flavors

---

**Note**: This setup provides a complete automated deployment pipeline. The AWS Mac runner will handle all builds and uploads automatically when you push to the main branch.
