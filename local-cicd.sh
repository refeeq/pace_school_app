#!/bin/bash

# Full CI/CD Pipeline for School App
# Run this script on your self-hosted machine

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
FLAVORS=("pace" "gaes" "cbsa" "dpsa" "iiss" "pbss" "pcbs" "pmbs" "sisd")
BUILD_DIR="build-artifacts"
LOG_DIR="logs"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Function to print colored output
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

# Function to log with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_DIR/cicd_$TIMESTAMP.log"
}

# Function to check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    # Check Flutter
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter not found. Please install Flutter first."
        exit 1
    fi
    print_status "Flutter found: $(flutter --version | head -1)"
    
    # Check Android SDK
    if [ -z "$ANDROID_HOME" ]; then
        print_error "ANDROID_HOME not set. Please set up Android SDK."
        exit 1
    fi
    print_status "Android SDK found: $ANDROID_HOME"
    
    # Check Java
    if ! command -v java &> /dev/null; then
        print_error "Java not found. Please install Java 17."
        exit 1
    fi
    print_status "Java found: $(java -version 2>&1 | head -1)"
    
    # Check if we're in the right directory
    if [ ! -f "pubspec.yaml" ]; then
        print_error "pubspec.yaml not found. Please run this script from the project root."
        exit 1
    fi
    print_status "Project directory confirmed"
}

# Function to setup environment
setup_environment() {
    log "Setting up environment..."
    
    # Create directories
    mkdir -p "$BUILD_DIR/$TIMESTAMP"
    mkdir -p "$LOG_DIR"
    
    # Set environment variables
    export ANDROID_HOME="$ANDROID_HOME"
    export ANDROID_SDK_ROOT="$ANDROID_SDK_ROOT"
    export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"
    
    print_status "Environment setup completed"
}

# Function to clean previous builds
clean_builds() {
    log "Cleaning previous builds..."
    flutter clean
    rm -rf build/
    print_status "Build cleanup completed"
}

# Function to get dependencies
get_dependencies() {
    log "Getting Flutter dependencies..."
    flutter pub get
    print_status "Dependencies resolved"
}

# Function to run tests
run_tests() {
    log "Running tests..."
    if flutter test; then
        print_status "All tests passed"
    else
        print_warning "Some tests failed, but continuing with build"
    fi
}

# Function to run analysis
run_analysis() {
    log "Running code analysis..."
    if flutter analyze; then
        print_status "Code analysis passed"
    else
        print_warning "Code analysis found issues, but continuing with build"
    fi
}

# Function to generate icons for a flavor
generate_icons() {
    local flavor=$1
    local icon_config="flutter_launcher_icons-$flavor.yaml"
    
    if [ -f "$icon_config" ]; then
        log "Generating icons for $flavor..."
        flutter pub run flutter_launcher_icons:main -f "$icon_config"
        print_status "Icons generated for $flavor"
    else
        print_warning "No icon config found for $flavor, skipping icon generation"
    fi
}

# Function to setup signing for a flavor
setup_signing() {
    local flavor=$1
    
    log "Setting up signing for $flavor..."
    
    # Create key.properties based on flavor
    if [ "$flavor" = "gaes" ]; then
        # GAES uses different credentials (you'll need to set these)
        cat > android/key.properties << EOF
storePassword=\${GAES_STORE_PASSWORD}
keyAlias=key0
keyPassword=\${GAES_KEY_PASSWORD}
storeFile=../gaes.key
EOF
        print_warning "GAES signing setup - please ensure GAES credentials are available"
    else
        # All other flavors use PACE credentials
        cat > android/key.properties << EOF
storePassword=\${PACE_STORE_PASSWORD}
keyAlias=pace
keyPassword=\${PACE_KEY_PASSWORD}
storeFile=../pace_key.jks
EOF
        print_warning "PACE signing setup - please ensure PACE credentials are available"
    fi
    
    print_status "Signing configuration created for $flavor"
}

# Function to build AAB for a flavor
build_aab() {
    local flavor=$1
    local target_file="lib/schools/$flavor/${flavor}_main.dart"
    
    log "Building AAB for $flavor..."
    
    # Generate icons
    generate_icons "$flavor"
    
    # Setup signing
    setup_signing "$flavor"
    
    # Build AAB
    if flutter build appbundle --release --flavor "$flavor" --target "$target_file" --verbose; then
        print_status "AAB built successfully for $flavor"
        
        # Copy AAB to build directory
        local aab_path="build/app/outputs/bundle/${flavor}Release/app-$flavor-release.aab"
        if [ -f "$aab_path" ]; then
            cp "$aab_path" "$BUILD_DIR/$TIMESTAMP/$flavor-release.aab"
            print_status "AAB copied to $BUILD_DIR/$TIMESTAMP/$flavor-release.aab"
        else
            print_error "AAB file not found for $flavor"
            return 1
        fi
    else
        print_error "AAB build failed for $flavor"
        return 1
    fi
}

# Function to build APK for a flavor (optional)
build_apk() {
    local flavor=$1
    local target_file="lib/schools/$flavor/${flavor}_main.dart"
    
    log "Building APK for $flavor..."
    
    if flutter build apk --release --flavor "$flavor" --target "$target_file"; then
        print_status "APK built successfully for $flavor"
        
        # Copy APK to build directory
        local apk_path="build/app/outputs/flutter-apk/app-$flavor-release.apk"
        if [ -f "$apk_path" ]; then
            cp "$apk_path" "$BUILD_DIR/$TIMESTAMP/$flavor-release.apk"
            print_status "APK copied to $BUILD_DIR/$TIMESTAMP/$flavor-release.apk"
        fi
    else
        print_warning "APK build failed for $flavor, continuing..."
    fi
}

# Function to upload to Play Store (if configured)
upload_to_playstore() {
    local flavor=$1
    local aab_file="$BUILD_DIR/$TIMESTAMP/$flavor-release.aab"
    
    if [ -f "$aab_file" ]; then
        log "Uploading $flavor to Play Store..."
        print_warning "Play Store upload not implemented in this script"
        print_info "AAB file ready for manual upload: $aab_file"
    else
        print_error "AAB file not found for $flavor upload"
    fi
}

# Function to create build summary
create_summary() {
    local summary_file="$BUILD_DIR/$TIMESTAMP/build_summary.txt"
    
    log "Creating build summary..."
    
    cat > "$summary_file" << EOF
Build Summary - $TIMESTAMP
============================

Build Date: $(date)
Flutter Version: $(flutter --version | head -1)
Android SDK: $ANDROID_HOME

Built Flavors:
EOF
    
    for flavor in "${FLAVORS[@]}"; do
        if [ -f "$BUILD_DIR/$TIMESTAMP/$flavor-release.aab" ]; then
            local size=$(ls -lh "$BUILD_DIR/$TIMESTAMP/$flavor-release.aab" | awk '{print $5}')
            echo "- $flavor: ✅ AAB ($size)" >> "$summary_file"
        else
            echo "- $flavor: ❌ Failed" >> "$summary_file"
        fi
    done
    
    echo "" >> "$summary_file"
    echo "Build Directory: $BUILD_DIR/$TIMESTAMP/" >> "$summary_file"
    echo "Log File: $LOG_DIR/cicd_$TIMESTAMP.log" >> "$summary_file"
    
    print_status "Build summary created: $summary_file"
}

# Function to cleanup
cleanup() {
    log "Cleaning up temporary files..."
    rm -f android/key.properties
    print_status "Cleanup completed"
}

# Main CI/CD pipeline
main() {
    echo "🚀 Starting Full CI/CD Pipeline for School App"
    echo "=============================================="
    
    # Check prerequisites
    check_prerequisites
    
    # Setup environment
    setup_environment
    
    # Clean previous builds
    clean_builds
    
    # Get dependencies
    get_dependencies
    
    # Run tests
    run_tests
    
    # Run analysis
    run_analysis
    
    # Build all flavors
    local success_count=0
    local total_count=${#FLAVORS[@]}
    
    for flavor in "${FLAVORS[@]}"; do
        echo ""
        print_info "Building $flavor ($((success_count + 1))/$total_count)..."
        
        if build_aab "$flavor"; then
            ((success_count++))
            print_status "$flavor build completed successfully"
        else
            print_error "$flavor build failed"
        fi
        
        # Optional: Build APK as well
        # build_apk "$flavor"
    done
    
    # Create build summary
    create_summary
    
    # Cleanup
    cleanup
    
    # Final summary
    echo ""
    echo "🎉 CI/CD Pipeline Completed!"
    echo "============================"
    echo "✅ Successful builds: $success_count/$total_count"
    echo "📁 Build artifacts: $BUILD_DIR/$TIMESTAMP/"
    echo "📝 Log file: $LOG_DIR/cicd_$TIMESTAMP.log"
    echo ""
    
    if [ $success_count -eq $total_count ]; then
        print_status "All flavors built successfully! 🎉"
    else
        print_warning "Some builds failed. Check the log for details."
    fi
}

# Run the pipeline
main "$@"
