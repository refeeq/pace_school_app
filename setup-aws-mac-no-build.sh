#!/bin/bash

# AWS Mac Setup Script for Auto-Deploy (No Build Test)
# Run this on your AWS Mac machine after cloning the repository

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

print_header "AWS Mac Auto-Deploy Setup (No Build Test)"

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

print_info "Setting up auto-deploy for school_app..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed. Please install Flutter first."
    echo "Install Flutter: https://docs.flutter.dev/get-started/install/macos"
    exit 1
fi

# Check if Android SDK is installed
if [ ! -d "$HOME/Library/Android/sdk" ]; then
    print_error "Android SDK is not installed. Please install Android Studio first."
    echo "Install Android Studio: https://developer.android.com/studio"
    exit 1
fi

print_status "Flutter and Android SDK found"

# Setup environment variables
print_info "Setting up environment variables..."
if ! grep -q "ANDROID_HOME" ~/.zshrc; then
    cat >> ~/.zshrc << 'ENVEOF'

# School App Auto-Deploy Environment
export ANDROID_HOME=$HOME/Library/Android/sdk
export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools
ENVEOF
    print_status "Environment variables added to ~/.zshrc"
else
    print_info "Environment variables already configured"
fi

# Reload shell
source ~/.zshrc

# Make scripts executable
print_info "Making scripts executable..."
chmod +x *.sh

# Setup git hooks for auto-pull
print_info "Setting up git hooks..."
if [ -f "setup-git-hooks.sh" ]; then
    ./setup-git-hooks.sh
else
    print_warning "setup-git-hooks.sh not found, skipping git hooks setup"
fi

# Setup notifications
print_info "Setting up notifications..."
if [ -f "notify-deployment.sh" ]; then
    ./notify-deployment.sh --setup
else
    print_warning "notify-deployment.sh not found, skipping notifications setup"
fi

# Skip test build - we'll do this after GitHub secrets are configured
print_warning "Skipping test build - will be done after GitHub secrets are configured"

# Create monitoring script
print_info "Creating monitoring script..."
cat > monitor-deployments.sh << 'EOF'
#!/bin/bash

# Deployment Monitoring Script
# Shows status of recent deployments

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

print_header "Deployment Status Monitor"

# Check recent deployments
echo "Recent deployments:"
if [ -d ~/playstore-deployments ]; then
    ls -la ~/playstore-deployments/ | head -10
else
    echo "No deployments found"
fi

echo ""
echo "Recent build logs:"
if [ -f logs/git-hooks.log ]; then
    tail -20 logs/git-hooks.log
else
    echo "No logs found"
fi

echo ""
echo "GitHub Actions status:"
if command -v gh &> /dev/null; then
    gh run list --limit 5
else
    echo "GitHub CLI not installed. Check GitHub Actions tab manually."
fi
EOF

chmod +x monitor-deployments.sh

print_status "AWS Mac setup completed!"
print_info ""
print_info "Your AWS Mac is now ready for auto-deploy!"
print_info ""
print_info "Next steps:"
print_info "1. Add GitHub secrets to your repository"
print_info "2. Run: ./test-build-after-secrets.sh (after adding secrets)"
print_info "3. Start auto-deploy: ./start-auto-deploy.sh"
print_info "4. Monitor with: ./monitor-deployments.sh"
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
