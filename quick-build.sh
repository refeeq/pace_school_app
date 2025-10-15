#!/bin/bash

# Quick Build Script for School App
# Builds specific flavors quickly

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
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

# Function to build a single flavor
build_flavor() {
    local flavor=$1
    local target_file="lib/schools/$flavor/${flavor}_main.dart"
    
    echo "Building $flavor..."
    
    # Generate icons
    if [ -f "flutter_launcher_icons-$flavor.yaml" ]; then
        flutter pub run flutter_launcher_icons:main -f "flutter_launcher_icons-$flavor.yaml"
    fi
    
    # Setup signing (simplified)
    cat > android/key.properties << EOF
storePassword=\${PACE_STORE_PASSWORD}
keyAlias=pace
keyPassword=\${PACE_KEY_PASSWORD}
storeFile=../pace_key.jks
EOF
    
    # Build AAB
    if flutter build appbundle --release --flavor "$flavor" --target "$target_file"; then
        print_status "$flavor built successfully"
        
        # Copy to build directory
        mkdir -p builds/$(date +%Y%m%d)
        cp "build/app/outputs/bundle/${flavor}Release/app-$flavor-release.aab" "builds/$(date +%Y%m%d)/$flavor-release.aab"
        print_status "AAB saved to builds/$(date +%Y%m%d)/$flavor-release.aab"
    else
        print_error "$flavor build failed"
        return 1
    fi
}

# Main function
main() {
    if [ $# -eq 0 ]; then
        echo "Usage: $0 <flavor1> [flavor2] [flavor3] ..."
        echo "Available flavors: pace, gaes, cbsa, dpsa, iiss, pbss, pcbs, pmbs, sisd"
        echo "Example: $0 pace gaes cbsa"
        exit 1
    fi
    
    echo "🚀 Quick Build for School App"
    echo "============================="
    
    # Clean and get dependencies
    flutter clean
    flutter pub get
    
    # Build specified flavors
    for flavor in "$@"; do
        build_flavor "$flavor"
    done
    
    print_status "Quick build completed!"
}

main "$@"
