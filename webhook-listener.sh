#!/bin/bash

# GitHub Webhook Listener for Auto CI/CD
# This script runs on your AWS Mac machine and listens for GitHub webhooks

set -e

# Configuration
WEBHOOK_PORT=8080
PROJECT_DIR="/Users/ec2-user/school_app"  # Adjust this path
WEBHOOK_SECRET="your_webhook_secret_here"  # Change this to a secure secret
LOG_FILE="logs/webhook.log"

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

# Function to log with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Function to verify GitHub webhook signature
verify_signature() {
    local payload="$1"
    local signature="$2"
    local secret="$3"
    
    if [ -z "$signature" ] || [ -z "$secret" ]; then
        return 1
    fi
    
    local expected_signature=$(echo -n "$payload" | openssl dgst -sha256 -hmac "$secret" | cut -d' ' -f2)
    local provided_signature=$(echo "$signature" | sed 's/sha256=//')
    
    if [ "$expected_signature" = "$provided_signature" ]; then
        return 0
    else
        return 1
    fi
}

# Function to handle webhook
handle_webhook() {
    local payload="$1"
    local event_type="$2"
    
    log "Received webhook: $event_type"
    
    # Only process push events to main branch
    if [ "$event_type" = "push" ]; then
        local ref=$(echo "$payload" | jq -r '.ref')
        local branch=$(echo "$ref" | sed 's/refs\/heads\///')
        
        if [ "$branch" = "main" ]; then
            log "Push to main branch detected, triggering build..."
            trigger_build
        else
            log "Push to $branch branch, ignoring"
        fi
    else
        log "Event type $event_type, ignoring"
    fi
}

# Function to trigger build
trigger_build() {
    log "Starting automated build..."
    
    # Change to project directory
    cd "$PROJECT_DIR" || {
        print_error "Failed to change to project directory: $PROJECT_DIR"
        return 1
    }
    
    # Pull latest changes
    log "Pulling latest changes..."
    git pull origin main || {
        print_error "Failed to pull latest changes"
        return 1
    }
    
    # Run the CI/CD pipeline
    log "Running CI/CD pipeline..."
    if ./local-cicd.sh; then
        print_status "Build completed successfully"
        log "Build completed successfully"
    else
        print_error "Build failed"
        log "Build failed"
    fi
}

# Function to start webhook server
start_webhook_server() {
    print_info "Starting webhook listener on port $WEBHOOK_PORT"
    print_info "Project directory: $PROJECT_DIR"
    print_info "Log file: $LOG_FILE"
    
    # Create logs directory
    mkdir -p "$(dirname "$LOG_FILE")"
    
    # Start webhook server
    while true; do
        {
            echo "HTTP/1.1 200 OK"
            echo "Content-Type: application/json"
            echo "Access-Control-Allow-Origin: *"
            echo "Access-Control-Allow-Methods: POST, OPTIONS"
            echo "Access-Control-Allow-Headers: Content-Type, X-GitHub-Event, X-Hub-Signature-256"
            echo ""
            echo '{"status": "ok"}'
        } | nc -l "$WEBHOOK_PORT" | {
            read -r method path version
            read -r host
            read -r content_type
            read -r content_length
            read -r github_event
            read -r github_signature
            read -r empty_line
            
            # Read payload
            if [ -n "$content_length" ] && [ "$content_length" -gt 0 ]; then
                payload=$(dd bs=1 count="$content_length" 2>/dev/null)
                
                # Verify signature
                if verify_signature "$payload" "$github_signature" "$WEBHOOK_SECRET"; then
                    handle_webhook "$payload" "$github_event"
                else
                    log "Invalid webhook signature"
                fi
            fi
        }
    done
}

# Function to setup as service
setup_service() {
    print_info "Setting up webhook listener as a service..."
    
    # Create launchd plist
    cat > ~/Library/LaunchAgents/com.schoolapp.webhook.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.schoolapp.webhook</string>
    <key>ProgramArguments</key>
    <array>
        <string>$PROJECT_DIR/webhook-listener.sh</string>
        <string>--daemon</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>$PROJECT_DIR/logs/webhook.log</string>
    <key>StandardErrorPath</key>
    <string>$PROJECT_DIR/logs/webhook-error.log</string>
</dict>
</plist>
EOF
    
    # Load the service
    launchctl load ~/Library/LaunchAgents/com.schoolapp.webhook.plist
    
    print_status "Webhook listener service installed"
    print_info "To start: launchctl start com.schoolapp.webhook"
    print_info "To stop: launchctl stop com.schoolapp.webhook"
    print_info "To uninstall: launchctl unload ~/Library/LaunchAgents/com.schoolapp.webhook.plist"
}

# Main function
main() {
    case "${1:-}" in
        --daemon)
            start_webhook_server
            ;;
        --setup-service)
            setup_service
            ;;
        --help)
            echo "GitHub Webhook Listener for School App CI/CD"
            echo ""
            echo "Usage: $0 [option]"
            echo ""
            echo "Options:"
            echo "  --daemon         Start webhook server"
            echo "  --setup-service  Install as macOS service"
            echo "  --help          Show this help"
            echo ""
            echo "Configuration:"
            echo "  Edit PROJECT_DIR and WEBHOOK_SECRET in this script"
            echo ""
            echo "GitHub Webhook Setup:"
            echo "  1. Go to your GitHub repository"
            echo "  2. Settings > Webhooks > Add webhook"
            echo "  3. Payload URL: http://your-aws-mac-ip:$WEBHOOK_PORT"
            echo "  4. Content type: application/json"
            echo "  5. Secret: $WEBHOOK_SECRET"
            echo "  6. Events: Just the push event"
            ;;
        *)
            print_info "Starting webhook listener..."
            print_info "Use --help for more options"
            start_webhook_server
            ;;
    esac
}

main "$@"
