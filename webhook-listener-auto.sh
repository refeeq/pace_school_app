#!/bin/bash

# Webhook Listener for Auto Pull and Build
# Listens for GitHub webhooks and triggers automatic builds

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Configuration
PORT=8080
REPO_DIR="/Users/hashiqvh/Projects/test/school_app"
LOG_FILE="$REPO_DIR/logs/webhook.log"
AUTO_BUILD_SCRIPT="$REPO_DIR/auto-pull-build.sh"

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
    print_info "Setting up webhook listener environment..."
    
    # Create log directory
    mkdir -p "$(dirname "$LOG_FILE")"
    
    # Make scripts executable
    chmod +x "$AUTO_BUILD_SCRIPT"
    
    print_status "Environment setup completed"
}

# Function to handle webhook payload
handle_webhook() {
    local payload="$1"
    
    print_info "Processing webhook payload..."
    
    # Extract branch from payload (simplified JSON parsing)
    local branch=$(echo "$payload" | grep -o '"ref":"[^"]*"' | cut -d'"' -f4 | sed 's/refs\/heads\///')
    
    print_info "Branch: $branch"
    
    # Only process main branch pushes
    if [ "$branch" = "main" ]; then
        print_info "Main branch push detected, triggering auto-build..."
        
        # Trigger auto-build in background
        nohup "$AUTO_BUILD_SCRIPT" > /dev/null 2>&1 &
        
        print_status "Auto-build triggered successfully"
    else
        print_info "Ignoring push to branch: $branch"
    fi
}

# Function to start webhook server
start_webhook_server() {
    print_header "Starting webhook listener on port $PORT"
    
    # Create a simple HTTP server using netcat
    while true; do
        print_info "Waiting for webhook on port $PORT..."
        
        # Listen for incoming connections
        echo -e "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: 2\r\n\r\nOK" | nc -l "$PORT" | while read -r line; do
            if [[ "$line" =~ ^POST ]]; then
                print_info "Webhook received: $line"
                
                # Read the payload
                local payload=""
                local content_length=0
                
                while read -r header; do
                    if [[ "$header" =~ ^Content-Length: ]]; then
                        content_length=$(echo "$header" | cut -d' ' -f2)
                    elif [[ "$header" =~ ^$ ]]; then
                        # Empty line, start reading payload
                        if [ "$content_length" -gt 0 ]; then
                            payload=$(head -c "$content_length")
                        fi
                        break
                    fi
                done
                
                # Handle the webhook
                if [ -n "$payload" ]; then
                    handle_webhook "$payload"
                fi
            fi
        done
        
        print_warning "Webhook connection closed, restarting..."
        sleep 1
    done
}

# Function to setup as a service
setup_service() {
    print_info "Setting up webhook listener as a service..."
    
    # Create plist for launchd service
    cat > ~/Library/LaunchAgents/com.schoolapp.webhook.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.schoolapp.webhook</string>
    <key>ProgramArguments</key>
    <array>
        <string>$0</string>
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
    <string>$REPO_DIR/logs/webhook.error.log</string>
</dict>
</plist>
EOF
    
    # Load the service
    launchctl load ~/Library/LaunchAgents/com.schoolapp.webhook.plist
    
    print_status "Webhook service created and loaded"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --port PORT        Set webhook port (default: 8080)"
    echo "  --setup-service    Setup as a launchd service"
    echo "  --start            Start webhook listener"
    echo "  --stop             Stop webhook listener"
    echo "  --status           Show webhook status"
    echo "  --help             Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 --start                    # Start webhook listener"
    echo "  $0 --setup-service --start   # Setup service and start"
    echo "  $0 --status                   # Check status"
}

# Function to check status
check_status() {
    print_info "Checking webhook listener status..."
    
    if pgrep -f "webhook-listener-auto.sh" > /dev/null; then
        print_status "Webhook listener is running"
        echo "PID: $(pgrep -f "webhook-listener-auto.sh")"
    else
        print_warning "Webhook listener is not running"
    fi
    
    if [ -f ~/Library/LaunchAgents/com.schoolapp.webhook.plist ]; then
        print_status "Service is installed"
    else
        print_warning "Service is not installed"
    fi
}

# Function to stop webhook
stop_webhook() {
    print_info "Stopping webhook listener..."
    
    # Kill running processes
    pkill -f "webhook-listener-auto.sh" || true
    
    # Unload service
    if [ -f ~/Library/LaunchAgents/com.schoolapp.webhook.plist ]; then
        launchctl unload ~/Library/LaunchAgents/com.schoolapp.webhook.plist
        print_status "Service unloaded"
    fi
    
    print_status "Webhook listener stopped"
}

# Main function
main() {
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --port)
                PORT="$2"
                shift 2
                ;;
            --setup-service)
                setup_service
                shift
                ;;
            --start)
                setup_environment
                start_webhook_server
                shift
                ;;
            --stop)
                stop_webhook
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
