#!/bin/bash

# GitHub Self-Hosted Runner Setup Script
# Run this on your AWS Mac machine

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
    echo -e "${PURPLE}🚀 $1${NC}"
}

print_header "GitHub Self-Hosted Runner Setup"

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script must be run on macOS"
    exit 1
fi

print_info "Setting up GitHub self-hosted runner on your AWS Mac..."

# Get repository URL
echo "Enter your GitHub repository URL:"
echo "Example: https://github.com/hashiqvh/school_app"
read -r REPO_URL

if [ -z "$REPO_URL" ]; then
    print_error "Repository URL is required"
    exit 1
fi

# Extract repository name
REPO_NAME=$(echo "$REPO_URL" | sed 's/.*github.com\///' | sed 's/\.git$//')
print_info "Repository: $REPO_NAME"

# Download runner
print_info "Downloading GitHub Actions runner..."
curl -o actions-runner-osx-x64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-osx-x64-2.311.0.tar.gz

# Extract runner
print_info "Extracting runner..."
tar xzf ./actions-runner-osx-x64-2.311.0.tar.gz

# Get registration token
echo ""
print_info "To get your registration token:"
print_info "1. Go to: https://github.com/$REPO_NAME/settings/actions/runners"
print_info "2. Click 'New self-hosted runner'"
print_info "3. Select 'macOS'"
print_info "4. Copy the registration token"
echo ""
echo "Enter your registration token:"
read -r REGISTRATION_TOKEN

if [ -z "$REGISTRATION_TOKEN" ]; then
    print_error "Registration token is required"
    exit 1
fi

# Configure runner
print_info "Configuring runner..."
./config.sh --url "https://github.com/$REPO_NAME" --token "$REGISTRATION_TOKEN"

# Create runner service
print_info "Creating runner service..."
cat > ~/Library/LaunchAgents/com.github.runner.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.github.runner</string>
    <key>ProgramArguments</key>
    <array>
        <string>$(pwd)/run.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>$(pwd)/runner.log</string>
    <key>StandardErrorPath</key>
    <string>$(pwd)/runner-error.log</string>
</dict>
</plist>
EOF

# Load the service
launchctl load ~/Library/LaunchAgents/com.github.runner.plist

print_status "GitHub self-hosted runner setup completed!"
print_info ""
print_info "Runner is now running as a service"
print_info "To check status: launchctl list | grep github"
print_info "To stop: launchctl unload ~/Library/LaunchAgents/com.github.runner.plist"
print_info "To start: launchctl load ~/Library/LaunchAgents/com.github.runner.plist"
print_info ""
print_info "Logs:"
print_info "  - Output: $(pwd)/runner.log"
print_info "  - Errors: $(pwd)/runner-error.log"
print_info ""
print_status "Your AWS Mac is now ready to run GitHub Actions! 🎉"
