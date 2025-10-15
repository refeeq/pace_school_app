#!/bin/bash

# Git Polling Auto Build Script
# Polls Git repository for changes and automatically builds when updates are detected

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
LOG_FILE="$REPO_DIR/logs/git-polling.log"
AUTO_BUILD_SCRIPT="$REPO_DIR/auto-pull-build.sh"
POLL_INTERVAL=60  # seconds
BRANCH="main"

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

# Function to setup environment
setup_environment() {
    print_info "Setting up Git polling environment..."
    
    # Create log directory
    mkdir -p "$(dirname "$LOG_FILE")"
    
    # Make scripts executable
    chmod +x "$AUTO_BUILD_SCRIPT"
    
    # Change to repo directory
    cd "$REPO_DIR"
    
    print_status "Environment setup completed"
}

# Function to check for Git changes
check_git_changes() {
    print_info "Checking for Git changes..."
    
    # Fetch latest changes
    git fetch origin "$BRANCH" > /dev/null 2>&1
    
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

# Function to trigger auto-build
trigger_auto_build() {
    print_info "Triggering auto-build..."
    
    # Run auto-build in background
    nohup "$AUTO_BUILD_SCRIPT" > /dev/null 2>&1 &
    
    print_status "Auto-build triggered successfully"
}

# Function to start polling
start_polling() {
    print_header "Starting Git polling for auto-build"
    print_info "Polling every $POLL_INTERVAL seconds"
    print_info "Monitoring branch: $BRANCH"
    print_info "Press Ctrl+C to stop"
    
    while true; do
        if check_git_changes; then
            print_info "Changes detected, triggering build..."
            trigger_auto_build
        fi
        
        sleep "$POLL_INTERVAL"
    done
}

# Function to setup as a service
setup_service() {
    print_info "Setting up Git polling as a service..."
    
    # Create plist for launchd service
    cat > ~/Library/LaunchAgents/com.schoolapp.gitpolling.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.schoolapp.gitpolling</string>
    <key>ProgramArguments</key>
    <array>
        <string>$0</string>
        <string>--start</string>
    </array>
    <key>WorkingDirectory</key>
    <string>$REPO_DIR</string>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>$LOG_FILE</string>
    <key>StandardErrorPath</key>
    <string>$REPO_DIR/logs/git-polling.error.log</string>
</dict>
</plist>
EOF
    
    # Load the service
    launchctl load ~/Library/LaunchAgents/com.schoolapp.gitpolling.plist
    
    print_status "Git polling service created and loaded"
}

# Function to check status
check_status() {
    print_info "Checking Git polling status..."
    
    if pgrep -f "git-polling-auto.sh" > /dev/null; then
        print_status "Git polling is running"
        echo "PID: $(pgrep -f "git-polling-auto.sh")"
    else
        print_warning "Git polling is not running"
    fi
    
    if [ -f ~/Library/LaunchAgents/com.schoolapp.gitpolling.plist ]; then
        print_status "Service is installed"
    else
        print_warning "Service is not installed"
    fi
}

# Function to stop polling
stop_polling() {
    print_info "Stopping Git polling..."
    
    # Kill running processes
    pkill -f "git-polling-auto.sh" || true
    
    # Unload service
    if [ -f ~/Library/LaunchAgents/com.schoolapp.gitpolling.plist ]; then
        launchctl unload ~/Library/LaunchAgents/com.schoolapp.gitpolling.plist
        print_status "Service unloaded"
    fi
    
    print_status "Git polling stopped"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --interval SECONDS  Set polling interval (default: 60)"
    echo "  --setup-service     Setup as a launchd service"
    echo "  --start             Start Git polling"
    echo "  --stop              Stop Git polling"
    echo "  --status            Show polling status"
    echo "  --help              Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 --start                    # Start Git polling"
    echo "  $0 --setup-service --start   # Setup service and start"
    echo "  $0 --status                   # Check status"
}

# Main function
main() {
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --interval)
                POLL_INTERVAL="$2"
                shift 2
                ;;
            --setup-service)
                setup_service
                shift
                ;;
            --start)
                setup_environment
                start_polling
                shift
                ;;
            --stop)
                stop_polling
                shift
                ;;
            --status)
                check_status
                shift
                ;;
            --help)
                show_usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # If no arguments, show usage
    if [ $# -eq 0 ]; then
        show_usage
    fi
}

# Run the main function
main "$@"
