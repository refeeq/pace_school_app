#!/bin/bash

# APK Installation Script
# Installs APK on connected Android device

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

# Check if ADB is available
if ! command -v adb &> /dev/null; then
    print_error "ADB is not installed. Please install Android SDK Platform Tools."
    exit 1
fi

# Check if device is connected
print_info "Checking for connected devices..."
DEVICES=$(adb devices | grep -v "List of devices" | grep -v "^$" | wc -l)

if [ "$DEVICES" -eq 0 ]; then
    print_error "No Android devices connected."
    print_info "Please connect your device and enable USB debugging."
    exit 1
fi

print_info "Found $DEVICES connected device(s)"

# Get available APK files
APK_FILES=($(find build/app/outputs/flutter-apk/ -name "*.apk" 2>/dev/null || true))

if [ ${#APK_FILES[@]} -eq 0 ]; then
    print_error "No APK files found. Please build the app first."
    print_info "Run: ./build-single.sh <flavor>"
    exit 1
fi

# Show available APK files
print_info "Available APK files:"
for i in "${!APK_FILES[@]}"; do
    echo "  $((i+1)). ${APK_FILES[$i]}"
done

# Let user select APK
if [ ${#APK_FILES[@]} -eq 1 ]; then
    SELECTED_APK="${APK_FILES[0]}"
    print_info "Auto-selecting: $SELECTED_APK"
else
    echo ""
    read -p "Select APK file (1-${#APK_FILES[@]}): " SELECTION
    
    if ! [[ "$SELECTION" =~ ^[0-9]+$ ]] || [ "$SELECTION" -lt 1 ] || [ "$SELECTION" -gt ${#APK_FILES[@]} ]; then
        print_error "Invalid selection"
        exit 1
    fi
    
    SELECTED_APK="${APK_FILES[$((SELECTION-1))]}"
fi

print_info "Installing: $SELECTED_APK"

# Uninstall existing app (if any)
print_info "Uninstalling existing app (if any)..."
adb uninstall com.pacesharjah.schoolapp 2>/dev/null || true

# Install APK
print_info "Installing APK..."
if adb install "$SELECTED_APK"; then
    print_status "APK installed successfully! 🎉"
    print_info "You can now open the app on your device."
else
    print_error "APK installation failed"
    exit 1
fi
