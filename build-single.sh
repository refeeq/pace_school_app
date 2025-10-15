#!/bin/bash

# Single Flavor Build Script
# Builds a specific flavor locally

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

# Available flavors
FLAVORS=("pace" "gaes" "cbsa" "dpsa" "iiss" "pbss" "pcbs" "pmbs" "sisd")

# Check if flavor is provided
if [ -z "$1" ]; then
    print_error "Please specify a flavor"
    echo ""
    echo "Available flavors:"
    for flavor in "${FLAVORS[@]}"; do
        echo "  - $flavor"
    done
    echo ""
    echo "Usage: $0 <flavor>"
    echo "Example: $0 pace"
    exit 1
fi

FLAVOR="$1"

# Check if flavor is valid
if [[ ! " ${FLAVORS[@]} " =~ " ${FLAVOR} " ]]; then
    print_error "Invalid flavor: $FLAVOR"
    echo ""
    echo "Available flavors:"
    for flavor in "${FLAVORS[@]}"; do
        echo "  - $flavor"
    done
    exit 1
fi

print_info "Building $FLAVOR flavor..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed. Please install Flutter first."
    exit 1
fi

# Check if Android SDK is available
if [ -z "$ANDROID_HOME" ]; then
    print_warning "ANDROID_HOME not set. Trying to find Android SDK..."
    if [ -d "$HOME/Library/Android/sdk" ]; then
        export ANDROID_HOME="$HOME/Library/Android/sdk"
        export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
        export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"
        print_info "Android SDK found at: $ANDROID_HOME"
    else
        print_error "Android SDK not found. Please install Android Studio."
        exit 1
    fi
fi

# Check if main file exists
MAIN_FILE="lib/schools/$FLAVOR/${FLAVOR}_main.dart"
if [ ! -f "$MAIN_FILE" ]; then
    print_error "Main file not found: $MAIN_FILE"
    exit 1
fi

# Get dependencies
print_info "Getting Flutter dependencies..."
flutter pub get

# Build APK
print_info "Building APK for $FLAVOR..."
if flutter build apk --release --flavor "$FLAVOR" --target "$MAIN_FILE"; then
    print_status "APK built successfully for $FLAVOR"
    APK_PATH="build/app/outputs/flutter-apk/app-$FLAVOR-release.apk"
    if [ -f "$APK_PATH" ]; then
        APK_SIZE=$(ls -lh "$APK_PATH" | awk '{print $5}')
        print_info "APK location: $APK_PATH ($APK_SIZE)"
        print_info "To install: adb install $APK_PATH"
    fi
else
    print_error "APK build failed for $FLAVOR"
    exit 1
fi

# Build AAB
print_info "Building AAB for $FLAVOR..."
if flutter build appbundle --release --flavor "$FLAVOR" --target "$MAIN_FILE"; then
    print_status "AAB built successfully for $FLAVOR"
    AAB_PATH="build/app/outputs/bundle/${FLAVOR}Release/app-$FLAVOR-release.aab"
    if [ -f "$AAB_PATH" ]; then
        AAB_SIZE=$(ls -lh "$AAB_PATH" | awk '{print $5}')
        print_info "AAB location: $AAB_PATH ($AAB_SIZE)"
        print_info "To upload to Play Store: Use this AAB file"
    fi
else
    print_error "AAB build failed for $FLAVOR"
    exit 1
fi

print_status "Build completed successfully for $FLAVOR! 🎉"
