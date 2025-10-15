#!/bin/bash

# Local Build Script for All Flavors
# Builds all 9 school flavors locally

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

# Configuration
FLAVORS=("pace" "gaes" "cbsa" "dpsa" "iiss" "pbss" "pcbs" "pmbs" "sisd")
BUILD_DIR="builds"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BUILD_PATH="$BUILD_DIR/$TIMESTAMP"

print_header "School App Local Build Script"

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

# Create build directory
print_info "Creating build directory: $BUILD_PATH"
mkdir -p "$BUILD_PATH"

# Get dependencies
print_info "Getting Flutter dependencies..."
flutter pub get

# Build summary
SUCCESS_COUNT=0
TOTAL_COUNT=${#FLAVORS[@]}

print_info "Building $TOTAL_COUNT flavors..."

# Build each flavor
for flavor in "${FLAVORS[@]}"; do
    print_info "Building $flavor..."
    
    # Check if main file exists
    MAIN_FILE="lib/schools/$flavor/${flavor}_main.dart"
    if [ ! -f "$MAIN_FILE" ]; then
        print_warning "Main file not found: $MAIN_FILE, skipping $flavor"
        continue
    fi
    
    # Build APK
    print_info "  Building APK for $flavor..."
    if flutter build apk --release --flavor "$flavor" --target "$MAIN_FILE"; then
        print_status "  APK built successfully for $flavor"
        
        # Copy APK
        APK_SOURCE="build/app/outputs/flutter-apk/app-$flavor-release.apk"
        APK_DEST="$BUILD_PATH/$flavor-release.apk"
        if [ -f "$APK_SOURCE" ]; then
            cp "$APK_SOURCE" "$APK_DEST"
            print_info "  APK copied to: $APK_DEST"
        fi
    else
        print_error "  APK build failed for $flavor"
        continue
    fi
    
    # Build AAB
    print_info "  Building AAB for $flavor..."
    if flutter build appbundle --release --flavor "$flavor" --target "$MAIN_FILE"; then
        print_status "  AAB built successfully for $flavor"
        
        # Copy AAB
        AAB_SOURCE="build/app/outputs/bundle/${flavor}Release/app-$flavor-release.aab"
        AAB_DEST="$BUILD_PATH/$flavor-release.aab"
        if [ -f "$AAB_SOURCE" ]; then
            cp "$AAB_SOURCE" "$AAB_DEST"
            print_info "  AAB copied to: $AAB_DEST"
        fi
    else
        print_error "  AAB build failed for $flavor"
        continue
    fi
    
    ((SUCCESS_COUNT++))
    print_status "✅ $flavor completed successfully"
    echo ""
done

# Create build summary
print_info "Creating build summary..."
cat > "$BUILD_PATH/build_summary.txt" << EOF
School App Build Summary
========================

Build Date: $(date)
Build Path: $BUILD_PATH
Total Flavors: $TOTAL_COUNT
Successful Builds: $SUCCESS_COUNT
Failed Builds: $((TOTAL_COUNT - SUCCESS_COUNT))

Flavors Built:
EOF

for flavor in "${FLAVORS[@]}"; do
    if [ -f "$BUILD_PATH/$flavor-release.apk" ] && [ -f "$BUILD_PATH/$flavor-release.aab" ]; then
        APK_SIZE=$(ls -lh "$BUILD_PATH/$flavor-release.apk" | awk '{print $5}')
        AAB_SIZE=$(ls -lh "$BUILD_PATH/$flavor-release.aab" | awk '{print $5}')
        echo "- $flavor: ✅ APK ($APK_SIZE), AAB ($AAB_SIZE)" >> "$BUILD_PATH/build_summary.txt"
    else
        echo "- $flavor: ❌ Failed" >> "$BUILD_PATH/build_summary.txt"
    fi
done

# Show results
print_header "Build Complete! 🎉"
print_info "Build Summary: $SUCCESS_COUNT/$TOTAL_COUNT flavors built successfully"
print_info "Build location: $BUILD_PATH"
print_info ""
print_info "Files created:"
ls -la "$BUILD_PATH"

print_info ""
print_info "To install APK on device:"
print_info "  adb install $BUILD_PATH/pace-release.apk"
print_info ""
print_info "To upload AAB to Play Store:"
print_info "  Use: $BUILD_PATH/pace-release.aab"
print_info ""
print_status "Build completed successfully! 🚀"
