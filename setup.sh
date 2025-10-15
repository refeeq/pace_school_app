#!/bin/bash

# ONE Simple Setup Script for AWS Mac Auto-Deploy
# This script does everything you need

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

print_header "AWS Mac Auto-Deploy Setup"

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script must be run on macOS"
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    print_error "Please run this script from the school_app directory"
    exit 1
fi

print_info "Setting up auto-deploy system..."

# Step 1: Check Flutter
print_info "Checking Flutter..."
if ! command -v flutter &> /dev/null; then
    print_error "Flutter not found. Install Flutter first: https://docs.flutter.dev/get-started/install/macos"
    exit 1
fi
print_status "Flutter found: $(flutter --version | head -1)"

# Step 2: Check Android SDK
print_info "Checking Android SDK..."
if [ ! -d "$HOME/Library/Android/sdk" ]; then
    print_error "Android SDK not found. Install Android Studio first: https://developer.android.com/studio"
    exit 1
fi
print_status "Android SDK found"

# Step 3: Setup environment variables
print_info "Setting up environment variables..."
if ! grep -q "ANDROID_HOME" ~/.zshrc; then
    cat >> ~/.zshrc << 'ENVEOF'

# School App Auto-Deploy Environment
export ANDROID_HOME=$HOME/Library/Android/sdk
export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools
ENVEOF
    print_status "Environment variables added"
else
    print_info "Environment variables already configured"
fi

# Reload environment
source ~/.zshrc

# Step 4: Create directories
print_info "Creating directories..."
mkdir -p logs
mkdir -p ~/playstore-deployments
print_status "Directories created"

# Step 5: Make scripts executable
print_info "Making scripts executable..."
chmod +x *.sh
print_status "Scripts made executable"

# Step 6: Setup Git polling
print_info "Setting up Git polling..."
if [ -f "git-polling-auto.sh" ]; then
    ./git-polling-auto.sh --setup-service
    print_status "Git polling service created"
else
    print_warning "git-polling-auto.sh not found"
fi

# Step 7: Create management scripts
print_info "Creating management scripts..."

# Start script
cat > start.sh << 'EOF'
#!/bin/bash
echo "🚀 Starting Auto-Deploy System..."

# Start GitHub Actions runner
if [ -f "run.sh" ]; then
    nohup ./run.sh > runner.log 2>&1 &
    echo "✅ GitHub Actions runner started"
fi

# Start Git polling
if [ -f "git-polling-auto.sh" ]; then
    ./git-polling-auto.sh --start &
    echo "✅ Git polling started"
fi

echo "✅ Auto-deploy system started!"
echo "Check status: ./status.sh"
EOF

# Stop script
cat > stop.sh << 'EOF'
#!/bin/bash
echo "🛑 Stopping Auto-Deploy System..."

# Stop GitHub Actions runner
pkill -f "run.sh" || echo "Runner not running"

# Stop Git polling
if [ -f "git-polling-auto.sh" ]; then
    ./git-polling-auto.sh --stop
fi

echo "✅ Auto-deploy system stopped!"
EOF

# Status script
cat > status.sh << 'EOF'
#!/bin/bash
echo "📊 Auto-Deploy System Status"
echo "============================"

# Check GitHub Actions runner
if pgrep -f "run.sh" > /dev/null; then
    echo "✅ GitHub Actions runner: Running"
else
    echo "❌ GitHub Actions runner: Not running"
fi

# Check Git polling
if pgrep -f "git-polling-auto.sh" > /dev/null; then
    echo "✅ Git polling: Running"
else
    echo "❌ Git polling: Not running"
fi

# Check deployments
echo ""
echo "Recent deployments:"
if [ -d ~/playstore-deployments ]; then
    ls -la ~/playstore-deployments/ | head -5
else
    echo "No deployments found"
fi

# Check logs
echo ""
echo "Recent logs:"
if [ -f logs/git-polling.log ]; then
    echo "Git polling log (last 5 lines):"
    tail -5 logs/git-polling.log
fi
EOF

# Test script
cat > test.sh << 'EOF'
#!/bin/bash
echo "🧪 Testing Auto-Deploy System"

# Check Flutter
if command -v flutter &> /dev/null; then
    echo "✅ Flutter: Available"
else
    echo "❌ Flutter: Not available"
    exit 1
fi

# Check Android SDK
if [ -n "$ANDROID_HOME" ]; then
    echo "✅ Android SDK: Configured"
else
    echo "❌ Android SDK: Not configured"
    exit 1
fi

# Check scripts
scripts=("auto-pull-build.sh" "git-polling-auto.sh" "start.sh" "stop.sh" "status.sh")
for script in "${scripts[@]}"; do
    if [ -x "$script" ]; then
        echo "✅ $script: Executable"
    else
        echo "❌ $script: Not executable"
        exit 1
    fi
done

echo "✅ All tests passed!"
echo ""
echo "Next steps:"
echo "1. Add GitHub secrets to your repository"
echo "2. Start system: ./start.sh"
echo "3. Test with: git push origin main"
EOF

# Make management scripts executable
chmod +x start.sh stop.sh status.sh test.sh

# Final summary
print_status "Setup completed successfully!"
print_info ""
print_info "🎉 Your AWS Mac is ready for auto-deploy!"
print_info ""
print_info "Simple commands:"
print_info "  ./start.sh    - Start auto-deploy system"
print_info "  ./stop.sh     - Stop auto-deploy system"
print_info "  ./status.sh   - Check system status"
print_info "  ./test.sh     - Test the system"
print_info ""
print_info "Next steps:"
print_info "1. Add GitHub secrets to your repository"
print_info "2. Run: ./start.sh"
print_info "3. Test with: git push origin main"
print_info ""
print_warning "No build test was run - this is normal!"
print_warning "The system will build automatically when you push to GitHub"
print_status "Setup complete! 🚀"
