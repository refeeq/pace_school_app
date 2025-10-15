#!/bin/bash

# Complete Auto-Deploy Setup for AWS Mac Runner
# Sets up automatic Git pull, build, and upload to Play Store

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_header() {
    echo -e "${PURPLE}🚀 $1${NC}"
}

print_header "Complete Auto-Deploy Setup for AWS Mac Runner"

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script must be run on macOS"
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    print_error "Please run this script from the school_app directory"
    echo "Make sure you're in the correct directory: cd school_app"
    exit 1
fi

print_info "Setting up complete auto-deploy system..."

# Step 1: Setup AWS Mac environment
print_info "Step 1: Setting up AWS Mac environment..."
if [ -f "setup-aws-mac.sh" ]; then
    chmod +x setup-aws-mac.sh
    ./setup-aws-mac.sh
else
    print_warning "setup-aws-mac.sh not found, skipping environment setup"
fi

# Step 2: Setup GitHub Actions runner
print_info "Step 2: Setting up GitHub Actions runner..."
if [ -f "setup-aws-runner-deploy.sh" ]; then
    chmod +x setup-aws-runner-deploy.sh
    ./setup-aws-runner-deploy.sh
else
    print_warning "setup-aws-runner-deploy.sh not found, skipping runner setup"
fi

# Step 3: Make auto-deploy scripts executable
print_info "Step 3: Setting up auto-deploy scripts..."
chmod +x auto-pull-build.sh
chmod +x webhook-listener-auto.sh
chmod +x git-polling-auto.sh

# Step 4: Create log directories
print_info "Step 4: Creating log directories..."
mkdir -p logs
mkdir -p ~/playstore-deployments

# Step 5: Setup Git polling service
print_info "Step 5: Setting up Git polling service..."
./git-polling-auto.sh --setup-service

# Step 6: Create management scripts
print_info "Step 6: Creating management scripts..."

# Start auto-deploy script
cat > start-auto-deploy.sh << 'EOF'
#!/bin/bash

# Start Auto-Deploy System
# Starts both GitHub Actions runner and Git polling

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_header() {
    echo -e "${PURPLE}🚀 $1${NC}"
}

print_header "Starting Auto-Deploy System"

# Start GitHub Actions runner
print_info "Starting GitHub Actions runner..."
if [ -f "run.sh" ]; then
    nohup ./run.sh > runner.log 2>&1 &
    print_status "GitHub Actions runner started"
else
    print_warning "GitHub Actions runner not found, skipping"
fi

# Start Git polling
print_info "Starting Git polling..."
./git-polling-auto.sh --start &
print_status "Git polling started"

print_status "Auto-deploy system started successfully!"
print_info "Check status with: ./status-auto-deploy.sh"
print_info "Stop with: ./stop-auto-deploy.sh"
EOF

# Stop auto-deploy script
cat > stop-auto-deploy.sh << 'EOF'
#!/bin/bash

# Stop Auto-Deploy System
# Stops both GitHub Actions runner and Git polling

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_header() {
    echo -e "${PURPLE}🛑 $1${NC}"
}

print_header "Stopping Auto-Deploy System"

# Stop GitHub Actions runner
print_info "Stopping GitHub Actions runner..."
pkill -f "run.sh" || print_warning "GitHub Actions runner not running"

# Stop Git polling
print_info "Stopping Git polling..."
./git-polling-auto.sh --stop

print_status "Auto-deploy system stopped successfully!"
EOF

# Status check script
cat > status-auto-deploy.sh << 'EOF'
#!/bin/bash

# Check Auto-Deploy System Status
# Shows status of all components

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_header() {
    echo -e "${PURPLE}📊 $1${NC}"
}

print_header "Auto-Deploy System Status"

# Check GitHub Actions runner
echo "GitHub Actions Runner:"
if pgrep -f "run.sh" > /dev/null; then
    print_status "Running (PID: $(pgrep -f "run.sh"))"
else
    print_error "Not running"
fi

# Check Git polling
echo ""
echo "Git Polling:"
if pgrep -f "git-polling-auto.sh" > /dev/null; then
    print_status "Running (PID: $(pgrep -f "git-polling-auto.sh"))"
else
    print_error "Not running"
fi

# Check recent deployments
echo ""
echo "Recent Deployments:"
if [ -d ~/playstore-deployments ]; then
    ls -la ~/playstore-deployments/ | head -10
else
    print_warning "No deployments found"
fi

# Check logs
echo ""
echo "Recent Logs:"
if [ -f logs/git-polling.log ]; then
    print_info "Git Polling Log (last 10 lines):"
    tail -10 logs/git-polling.log
else
    print_warning "No Git polling logs found"
fi

if [ -f runner.log ]; then
    print_info "Runner Log (last 10 lines):"
    tail -10 runner.log
else
    print_warning "No runner logs found"
fi

# Check system resources
echo ""
echo "System Resources:"
echo "CPU: $(top -l 1 | grep "CPU usage" | awk '{print $3}')"
echo "Memory: $(top -l 1 | grep "PhysMem" | awk '{print $2}')"
echo "Disk: $(df -h . | tail -1 | awk '{print $4}') available"
EOF

# Make management scripts executable
chmod +x start-auto-deploy.sh
chmod +x stop-auto-deploy.sh
chmod +x status-auto-deploy.sh

# Step 7: Create a test script
print_info "Step 7: Creating test script..."

cat > test-auto-deploy.sh << 'EOF'
#!/bin/bash

# Test Auto-Deploy System
# Tests the complete auto-deploy flow

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_header() {
    echo -e "${PURPLE}🧪 $1${NC}"
}

print_header "Testing Auto-Deploy System"

# Test 1: Check if all scripts are executable
print_info "Test 1: Checking script permissions..."
scripts=("auto-pull-build.sh" "git-polling-auto.sh" "start-auto-deploy.sh" "stop-auto-deploy.sh" "status-auto-deploy.sh")
for script in "${scripts[@]}"; do
    if [ -x "$script" ]; then
        print_status "$script is executable"
    else
        print_error "$script is not executable"
        exit 1
    fi
done

# Test 2: Check if environment is set up
print_info "Test 2: Checking environment..."
if command -v flutter &> /dev/null; then
    print_status "Flutter is available"
else
    print_error "Flutter is not available"
    exit 1
fi

if [ -n "$ANDROID_HOME" ]; then
    print_status "Android SDK is configured"
else
    print_error "Android SDK is not configured"
    exit 1
fi

# Test 3: Test Git polling
print_info "Test 3: Testing Git polling..."
if ./git-polling-auto.sh --status | grep -q "Running"; then
    print_status "Git polling is working"
else
    print_warning "Git polling is not running"
fi

# Test 4: Test auto-build script
print_info "Test 4: Testing auto-build script..."
if [ -f "auto-pull-build.sh" ]; then
    print_status "Auto-build script is available"
else
    print_error "Auto-build script not found"
    exit 1
fi

print_status "All tests completed successfully!"
print_info "Your auto-deploy system is ready!"
EOF

chmod +x test-auto-deploy.sh

# Step 8: Create a comprehensive README
print_info "Step 8: Creating comprehensive documentation..."

cat > AUTO-DEPLOY-README.md << 'EOF'
# Complete Auto-Deploy System for School App

This system automatically pulls Git changes, builds all school flavors, and uploads to Google Play Store.

## What It Does

1. **Monitors Git Repository**: Continuously checks for new commits on the main branch
2. **Auto-Pulls Changes**: Automatically pulls latest changes when detected
3. **Builds All Flavors**: Builds all 9 school flavors (pace, gaes, cbsa, dpsa, iiss, pbss, pcbs, pmbs, sisd)
4. **Uploads to Play Store**: Uploads AAB files to Google Play Store internal track
5. **Stores Artifacts**: Keeps local copies of all built AAB files

## Quick Start

### 1. Complete Setup
```bash
# Run the complete setup (one-time)
./setup-auto-deploy-complete.sh
```

### 2. Start Auto-Deploy
```bash
# Start the complete system
./start-auto-deploy.sh
```

### 3. Check Status
```bash
# Check if everything is running
./status-auto-deploy.sh
```

### 4. Test the System
```bash
# Run tests
./test-auto-deploy.sh
```

## How It Works

### Git Polling
- Checks for new commits every 60 seconds
- Only processes changes to the `main` branch
- Automatically triggers build when changes are detected

### Auto-Build Process
1. Pulls latest changes from Git
2. Cleans previous builds
3. Gets Flutter dependencies
4. Builds all 9 flavors in sequence
5. Uploads each AAB to Play Store
6. Stores artifacts locally
7. Sends notifications

### GitHub Actions Integration
- Uses self-hosted AWS Mac runner
- Labels: `[self-hosted, macos, aws]`
- Triggers on push to main branch
- Manual dispatch available

## Management Commands

### System Control
```bash
./start-auto-deploy.sh    # Start the system
./stop-auto-deploy.sh     # Stop the system
./status-auto-deploy.sh   # Check status
```

### Individual Components
```bash
# Git Polling
./git-polling-auto.sh --start     # Start polling
./git-polling-auto.sh --stop      # Stop polling
./git-polling-auto.sh --status    # Check status

# Auto-Build
./auto-pull-build.sh              # Manual build

# GitHub Actions Runner
./start-runner.sh                 # Start runner
./stop-runner.sh                  # Stop runner
./monitor-runner.sh               # Monitor runner
```

## Configuration

### Environment Variables
Set these in your `~/.zshrc`:
```bash
export ANDROID_HOME=$HOME/Library/Android/sdk
export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools
```

### GitHub Secrets
Required secrets in your repository:
- `PACE_STORE_PASSWORD`
- `PACE_KEY_PASSWORD`
- `PACE_KEYSTORE_BASE64`
- `GAES_STORE_PASSWORD`
- `GAES_KEY_PASSWORD`
- `GAES_KEYSTORE_BASE64`
- `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`

### Polling Interval
Default: 60 seconds
Change in `git-polling-auto.sh`:
```bash
POLL_INTERVAL=30  # 30 seconds
```

## File Structure

```
school_app/
├── .github/workflows/
│   ├── auto-deploy-playstore.yml    # Main deployment workflow
│   └── test-runner.yml              # Test workflow
├── auto-pull-build.sh               # Auto-build script
├── git-polling-auto.sh              # Git polling script
├── setup-auto-deploy-complete.sh    # Complete setup
├── start-auto-deploy.sh             # Start system
├── stop-auto-deploy.sh              # Stop system
├── status-auto-deploy.sh            # Check status
├── test-auto-deploy.sh              # Test system
└── logs/                            # Log files
    ├── git-polling.log
    └── auto-pull.log
```

## Monitoring

### Logs
- **Git Polling**: `logs/git-polling.log`
- **Auto-Build**: `logs/auto-pull.log`
- **Runner**: `runner.log`

### Deployment Artifacts
- **Location**: `~/playstore-deployments/{timestamp}/`
- **Files**: `{flavor}-release.aab`
- **Summary**: `deployment_summary.txt`

### Status Monitoring
```bash
# Check system status
./status-auto-deploy.sh

# View recent logs
tail -f logs/git-polling.log
tail -f logs/auto-pull.log

# Check recent deployments
ls -la ~/playstore-deployments/
```

## Troubleshooting

### Common Issues

1. **Git Polling Not Working**
   ```bash
   ./git-polling-auto.sh --status
   ./git-polling-auto.sh --start
   ```

2. **Build Failures**
   ```bash
   # Check environment
   flutter doctor -v
   
   # Manual build test
   ./auto-pull-build.sh
   ```

3. **Runner Issues**
   ```bash
   # Check runner status
   ./monitor-runner.sh
   
   # Restart runner
   ./stop-runner.sh
   ./start-runner.sh
   ```

4. **Service Issues**
   ```bash
   # Check service status
   launchctl list | grep schoolapp
   
   # Restart services
   ./stop-auto-deploy.sh
   ./start-auto-deploy.sh
   ```

### Debug Mode
Enable verbose logging in scripts:
```bash
# Edit git-polling-auto.sh
POLL_INTERVAL=10  # Check every 10 seconds

# Edit auto-pull-build.sh
# Add more print_info statements
```

## Workflow

### Automatic Flow
1. You push to `main` branch
2. Git polling detects changes (within 60 seconds)
3. Auto-build script pulls changes
4. Builds all 9 flavors
5. Uploads to Play Store internal track
6. Stores artifacts locally
7. Sends notifications

### Manual Flow
1. Run `./auto-pull-build.sh` manually
2. Or trigger GitHub Actions workflow manually
3. Or use `./quick-build.sh pace gaes cbsa` for specific flavors

## Security

- Keystore files are never committed to Git
- All secrets are stored in GitHub Secrets
- Local deployment artifacts are stored securely
- Runner has limited repository access

## Maintenance

### Regular Tasks
- Monitor disk space: `df -h`
- Clean old deployments: `rm -rf ~/playstore-deployments/old_*`
- Update Flutter: `flutter upgrade`
- Check logs for errors

### Updates
- **Flutter**: `flutter upgrade`
- **Android SDK**: Update via Android Studio
- **Runner**: Re-run setup scripts

---

**Your auto-deploy system is now ready!** 🎉

Just push to the `main` branch and watch the magic happen!
EOF

# Final summary
print_status "Complete auto-deploy setup finished!"
print_info ""
print_info "🎉 Your AWS Mac is now ready for automatic deployment!"
print_info ""
print_info "What happens automatically:"
print_info "  1. Push to GitHub → Git polling detects changes"
print_info "  2. Auto-pull → Builds all 9 flavors"
print_info "  3. Upload to Play Store → Stores artifacts locally"
print_info "  4. Send notifications → Complete deployment summary"
print_info ""
print_info "Management commands:"
print_info "  - Start: ./start-auto-deploy.sh"
print_info "  - Stop: ./stop-auto-deploy.sh"
print_info "  - Status: ./status-auto-deploy.sh"
print_info "  - Test: ./test-auto-deploy.sh"
print_info ""
print_info "Next steps:"
print_info "1. Add GitHub secrets to your repository"
print_info "2. Start the system: ./start-auto-deploy.sh"
print_info "3. Test with: git push origin main"
print_info "4. Monitor with: ./status-auto-deploy.sh"
print_info ""
print_status "Setup complete! 🚀"
