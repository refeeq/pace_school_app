#!/bin/bash

# Auto Pull and Build Script for AWS Mac Runner
# This script automatically pulls changes and triggers builds when Git is updated

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Configuration
REPO_DIR="/Users/hashiqvh/Projects/test/school_app"
LOG_FILE="$REPO_DIR/logs/auto-pull.log"
LOCK_FILE="/tmp/auto-pull.lock"
BRANCH="main"
FLAVORS=("pace" "gaes" "cbsa" "dpsa" "iiss" "pbss" "pcbs" "pmbs" "sisd")

print_status() {
    echo -e "${GREEN}✅ $1${NC}"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ✅ $1" >> "$LOG_FILE"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ⚠️  $1" >> "$LOG_FILE"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ❌ $1" >> "$LOG_FILE"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ℹ️  $1" >> "$LOG_FILE"
}

print_header() {
    echo -e "${PURPLE}🚀 $1${NC}"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 🚀 $1" >> "$LOG_FILE"
}

# Function to check if another instance is running
check_lock() {
    if [ -f "$LOCK_FILE" ]; then
        local pid=$(cat "$LOCK_FILE")
        if ps -p "$pid" > /dev/null 2>&1; then
            print_warning "Another auto-pull process is running (PID: $pid)"
            exit 0
        else
            rm -f "$LOCK_FILE"
        fi
    fi
    echo $$ > "$LOCK_FILE"
}

# Function to cleanup lock file
cleanup() {
    rm -f "$LOCK_FILE"
    print_info "Cleanup completed"
}

# Function to setup environment
setup_environment() {
    print_info "Setting up environment..."
    
    # Create log directory
    mkdir -p "$(dirname "$LOG_FILE")"
    
    # Source environment variables
    source ~/.zshrc
    
    # Change to repo directory
    cd "$REPO_DIR"
    
    print_status "Environment setup completed"
}

# Function to check for Git changes
check_git_changes() {
    print_info "Checking for Git changes..."
    
    # Fetch latest changes
    git fetch origin "$BRANCH"
    
    # Check if there are new commits
    local local_commit=$(git rev-parse HEAD)
    local remote_commit=$(git rev-parse origin/$BRANCH)
    
    if [ "$local_commit" != "$remote_commit" ]; then
        print_info "New changes detected!"
        print_info "Local:  $local_commit"
        print_info "Remote: $remote_commit"
        return 0
    else
        print_info "No new changes detected"
        return 1
    fi
}

# Function to pull changes
pull_changes() {
    print_info "Pulling latest changes..."
    
    # Stash any local changes
    if ! git diff --quiet; then
        print_warning "Stashing local changes..."
        git stash push -m "Auto-stash before pull $(date)"
    fi
    
    # Pull latest changes
    git pull origin "$BRANCH"
    
    print_status "Changes pulled successfully"
}

# Function to setup signing for a flavor
setup_signing() {
    local flavor=$1
    
    print_info "Setting up signing for $flavor..."
    
    if [ "$flavor" = "gaes" ]; then
        # GAES uses different credentials
        cat > android/key.properties << EOF
storePassword=\${GAES_STORE_PASSWORD}
keyAlias=key0
keyPassword=\${GAES_KEY_PASSWORD}
storeFile=../gaes.key
EOF
    else
        # All other flavors use PACE credentials
        cat > android/key.properties << EOF
storePassword=\${PACE_STORE_PASSWORD}
keyAlias=pace
keyPassword=\${PACE_KEY_PASSWORD}
storeFile=../pace_key.jks
EOF
    fi
    
    print_status "Signing setup completed for $flavor"
}

# Function to build a single flavor
build_flavor() {
    local flavor=$1
    local target_file="lib/schools/$flavor/${flavor}_main.dart"
    
    print_info "Building $flavor..."
    
    # Generate icons
    if [ -f "flutter_launcher_icons-$flavor.yaml" ]; then
        flutter pub run flutter_launcher_icons:main -f "flutter_launcher_icons-$flavor.yaml"
    fi
    
    # Setup signing
    setup_signing "$flavor"
    
    # Build AAB
    if flutter build appbundle --release --flavor "$flavor" --target "$target_file" --verbose; then
        print_status "$flavor built successfully"
        
        # Copy to deployment directory
        local deploy_dir="$HOME/playstore-deployments/$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$deploy_dir"
        
        local aab_path="build/app/outputs/bundle/${flavor}Release/app-$flavor-release.aab"
        if [ -f "$aab_path" ]; then
            cp "$aab_path" "$deploy_dir/$flavor-release.aab"
            print_status "AAB copied to $deploy_dir/$flavor-release.aab"
            return 0
        else
            print_error "AAB file not found for $flavor"
            return 1
        fi
    else
        print_error "$flavor build failed"
        return 1
    fi
}

# Function to upload to Play Store
upload_to_playstore() {
    local flavor=$1
    local aab_file="$1"
    
    if [ -f "$aab_file" ]; then
        print_info "Uploading $flavor to Play Store..."
        
        # Use the upload-google-play action logic
        # This is a simplified version - you might want to use the actual action
        print_warning "Play Store upload not implemented in this script"
        print_info "AAB file ready for upload: $aab_file"
    else
        print_error "AAB file not found for $flavor upload"
    fi
}

# Function to build all flavors
build_all_flavors() {
    print_header "Building all flavors..."
    
    local success_count=0
    local total_count=${#FLAVORS[@]}
    local deploy_dir="$HOME/playstore-deployments/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$deploy_dir"
    
    # Clean and get dependencies
    flutter clean
    flutter pub get
    
    for flavor in "${FLAVORS[@]}"; do
        print_info "Building $flavor ($((success_count + 1))/$total_count)..."
        
        if build_flavor "$flavor"; then
            ((success_count++))
            print_status "$flavor build completed successfully"
        else
            print_error "$flavor build failed"
        fi
    done
    
    # Create deployment summary
    create_deployment_summary "$deploy_dir" "$success_count" "$total_count"
    
    print_status "Build process completed: $success_count/$total_count successful"
}

# Function to create deployment summary
create_deployment_summary() {
    local deploy_dir=$1
    local success_count=$2
    local total_count=$3
    
    print_info "Creating deployment summary..."
    
    cat > "$deploy_dir/deployment_summary.txt" << EOF
Auto-Deploy Summary
==================

Deployment Date: $(date)
Triggered by: Auto-pull from Git
Branch: $BRANCH
Track: internal

Build Results: $success_count/$total_count successful

Built Flavors:
EOF
    
    for flavor in "${FLAVORS[@]}"; do
        if [ -f "$deploy_dir/$flavor-release.aab" ]; then
            local size=$(ls -lh "$deploy_dir/$flavor-release.aab" | awk '{print $5}')
            echo "- $flavor: ✅ Built ($size)" >> "$deploy_dir/deployment_summary.txt"
        else
            echo "- $flavor: ❌ Failed" >> "$deploy_dir/deployment_summary.txt"
        fi
    done
    
    echo "" >> "$deploy_dir/deployment_summary.txt"
    echo "Deployment Directory: $deploy_dir/" >> "$deploy_dir/deployment_summary.txt"
    echo "Log File: $LOG_FILE" >> "$deploy_dir/deployment_summary.txt"
    
    print_status "Deployment summary created: $deploy_dir/deployment_summary.txt"
}

# Function to cleanup build artifacts
cleanup_build() {
    print_info "Cleaning up build artifacts..."
    
    # Clean up signing files
    rm -f android/key.properties
    rm -f android/*.jks
    rm -f android/*.key
    
    # Clean Flutter build cache
    flutter clean
    
    # Clean up temporary files
    rm -rf /tmp/flutter_*
    
    print_status "Build cleanup completed"
}

# Main function
main() {
    print_header "Auto Pull and Build Process Started"
    
    # Set up trap for cleanup
    trap cleanup EXIT
    
    # Check for lock
    check_lock
    
    # Setup environment
    setup_environment
    
    # Check for Git changes
    if check_git_changes; then
        # Pull changes
        pull_changes
        
        # Build all flavors
        build_all_flavors
        
        # Cleanup
        cleanup_build
        
        print_status "Auto pull and build completed successfully! 🎉"
    else
        print_info "No changes to build"
    fi
}

# Run the main function
main "$@"
