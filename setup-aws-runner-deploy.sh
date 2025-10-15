#!/bin/bash

# AWS Mac Runner Setup for Auto-Deploy
# Complete setup script for self-hosted GitHub Actions runner

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

print_header "AWS Mac Runner Setup for Auto-Deploy"

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

print_info "Setting up AWS Mac runner for auto-deploy..."

# Step 1: Setup AWS Mac environment (if not already done)
if [ ! -f "setup-aws-mac.sh" ]; then
    print_error "setup-aws-mac.sh not found. Please ensure you have the complete setup."
    exit 1
fi

print_info "Running AWS Mac environment setup..."
if [ -f "setup-aws-mac.sh" ]; then
    chmod +x setup-aws-mac.sh
    ./setup-aws-mac.sh
else
    print_warning "setup-aws-mac.sh not found, skipping environment setup"
fi

# Step 2: Clean up old runner files
print_info "Cleaning up old runner files..."
rm -rf actions-runner-osx-x64-*.tar.gz
rm -rf _diag .runner .credentials .credentials_rsaparams .token

# Step 3: Download latest runner
print_info "Downloading latest GitHub Actions runner..."
LATEST_VERSION=$(curl -s https://api.github.com/repos/actions/runner/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
RUNNER_VERSION=${LATEST_VERSION#v}
RUNNER_FILE="actions-runner-osx-x64-${RUNNER_VERSION}.tar.gz"

echo "Downloading runner version: $RUNNER_VERSION"
curl -o "$RUNNER_FILE" -L "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-osx-x64-${RUNNER_VERSION}.tar.gz"

# Step 4: Extract runner
print_info "Extracting runner..."
tar xzf "./$RUNNER_FILE"

# Step 5: Get registration token
print_info "Getting registration token..."
echo ""
echo "🔑 Get your registration token:"
echo "1. Go to: https://github.com/hashiqvh/school_app/settings/actions/runners"
echo "2. Click 'New self-hosted runner'"
echo "3. Select 'macOS'"
echo "4. Copy the token"
echo ""
read -p "Enter your registration token: " TOKEN

# Step 6: Configure runner with proper labels
print_info "Configuring runner with auto-deploy labels..."
./config.sh --url https://github.com/hashiqvh/school_app --token "$TOKEN" --labels "self-hosted,macos,aws" --name "aws-mac-auto-deploy"

# Step 7: Create runner service (optional - for auto-start)
print_info "Setting up runner service..."
if command -v launchctl &> /dev/null; then
    # Create plist for launchd service
    cat > ~/Library/LaunchAgents/com.github.actions.runner.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.github.actions.runner</string>
    <key>ProgramArguments</key>
    <array>
        <string>$(pwd)/run.sh</string>
    </array>
    <key>WorkingDirectory</key>
    <string>$(pwd)</string>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>$(pwd)/runner.log</string>
    <key>StandardErrorPath</key>
    <string>$(pwd)/runner.error.log</string>
</dict>
</plist>
EOF
    
    # Load the service
    launchctl load ~/Library/LaunchAgents/com.github.actions.runner.plist
    print_status "Runner service created and loaded"
else
    print_warning "launchctl not available, skipping service setup"
fi

# Step 8: Create monitoring script
print_info "Creating monitoring script..."
cat > monitor-runner.sh << 'EOF'
#!/bin/bash

# AWS Mac Runner Monitor
# Shows runner status and recent activity

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

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_header() {
    echo -e "${PURPLE}📊 $1${NC}"
}

print_header "AWS Mac Runner Status"

# Check if runner is running
if pgrep -f "run.sh" > /dev/null; then
    print_status "Runner is running"
else
    print_error "Runner is not running"
fi

# Check recent deployments
echo ""
print_info "Recent deployments:"
if [ -d ~/playstore-deployments ]; then
    ls -la ~/playstore-deployments/ | head -10
else
    echo "No deployments found"
fi

# Check runner logs
echo ""
print_info "Recent runner logs:"
if [ -f runner.log ]; then
    tail -20 runner.log
else
    echo "No runner logs found"
fi

# Check GitHub Actions status
echo ""
print_info "GitHub Actions status:"
if command -v gh &> /dev/null; then
    gh run list --limit 5
else
    echo "GitHub CLI not installed. Check GitHub Actions tab manually."
fi

# Check system resources
echo ""
print_info "System resources:"
echo "CPU: $(top -l 1 | grep "CPU usage" | awk '{print $3}')"
echo "Memory: $(top -l 1 | grep "PhysMem" | awk '{print $2}')"
echo "Disk: $(df -h . | tail -1 | awk '{print $4}') available"
EOF

chmod +x monitor-runner.sh

# Step 9: Create start/stop scripts
print_info "Creating start/stop scripts..."

# Start script
cat > start-runner.sh << 'EOF'
#!/bin/bash
echo "🚀 Starting GitHub Actions runner..."
./run.sh
EOF

# Stop script
cat > stop-runner.sh << 'EOF'
#!/bin/bash
echo "🛑 Stopping GitHub Actions runner..."
pkill -f "run.sh" || echo "Runner not running"
EOF

chmod +x start-runner.sh stop-runner.sh

# Step 10: Test the setup
print_info "Testing runner setup..."
if [ -f "run.sh" ]; then
    print_status "Runner files are ready"
else
    print_error "Runner setup failed"
    exit 1
fi

# Final summary
print_status "AWS Mac Runner setup completed!"
print_info ""
print_info "Your AWS Mac runner is now ready for auto-deploy!"
print_info ""
print_info "Runner details:"
print_info "  - Name: aws-mac-auto-deploy"
print_info "  - Labels: self-hosted, macos, aws"
print_info "  - Service: Auto-starts on boot (if launchctl available)"
print_info ""
print_info "Management commands:"
print_info "  - Start: ./start-runner.sh"
print_info "  - Stop: ./stop-runner.sh"
print_info "  - Monitor: ./monitor-runner.sh"
print_info ""
print_info "What happens automatically:"
print_info "  - Push to GitHub → Triggers workflow"
print_info "  - AWS Mac pulls code → Builds all flavors"
print_info "  - Uploads to Play Store → Sends notifications"
print_info ""
print_info "GitHub Secrets needed:"
print_info "  - PACE_STORE_PASSWORD"
print_info "  - PACE_KEY_PASSWORD"
print_info "  - PACE_KEYSTORE_BASE64"
print_info "  - GAES_STORE_PASSWORD"
print_info "  - GAES_KEY_PASSWORD"
print_info "  - GAES_KEYSTORE_BASE64"
print_info "  - GOOGLE_PLAY_SERVICE_ACCOUNT_JSON"
print_info ""
print_status "Setup complete! 🎉"
print_info ""
print_warning "Next steps:"
print_info "1. Add GitHub secrets to your repository"
print_info "2. Test with: git push origin main"
print_info "3. Monitor with: ./monitor-runner.sh"
print_info "4. Check GitHub Actions tab for workflow runs"
