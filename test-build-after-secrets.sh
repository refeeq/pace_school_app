#!/bin/bash

# Test Build After GitHub Secrets Are Configured
# Run this after you've added all the GitHub secrets to your repository

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

print_header "Testing Build After GitHub Secrets Configuration"

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    print_error "Please run this script from the school_app directory"
    exit 1
fi

# Source environment variables
source ~/.zshrc

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not available. Please run setup-aws-mac-no-build.sh first."
    exit 1
fi

# Check if Android SDK is configured
if [ -z "$ANDROID_HOME" ]; then
    print_error "ANDROID_HOME is not set. Please run setup-aws-mac-no-build.sh first."
    exit 1
fi

print_info "Environment check passed"

# Test Flutter doctor
print_info "Running Flutter doctor..."
flutter doctor

# Get dependencies
print_info "Getting Flutter dependencies..."
flutter pub get

# Test build for PACE flavor only (without signing first)
print_info "Testing build for PACE flavor (without signing)..."
if flutter build appbundle --release --flavor pace --target "lib/schools/pace/pace_main.dart" --no-tree-shake-icons; then
    print_status "PACE build test successful (without signing)"
else
    print_error "PACE build test failed"
    exit 1
fi

# Clean up test build
flutter clean

print_status "Build test completed successfully!"
print_info ""
print_info "Your environment is ready for auto-deploy!"
print_info ""
print_info "Next steps:"
print_info "1. Make sure all GitHub secrets are added to your repository"
print_info "2. Start the auto-deploy system: ./start-auto-deploy.sh"
print_info "3. Test with a real push to GitHub"
print_info ""
print_warning "Note: The actual builds will use GitHub secrets for signing"
print_warning "This test was done without signing to verify the build process works"
