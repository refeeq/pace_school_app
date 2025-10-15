#!/bin/bash

# Deployment Notification Script
# Sends notifications when builds complete

set -e

# Configuration
WEBHOOK_URL=""  # Add your Slack/Discord webhook URL here
EMAIL=""        # Add your email for notifications
LOG_FILE="logs/notifications.log"

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

# Function to send Slack notification
send_slack_notification() {
    local message="$1"
    local status="$2"
    local color="$3"
    
    if [ -n "$WEBHOOK_URL" ]; then
        curl -X POST -H 'Content-type: application/json' \
            --data "{
                \"text\": \"🚀 School App Deployment\",
                \"attachments\": [{
                    \"color\": \"$color\",
                    \"fields\": [{
                        \"title\": \"Status\",
                        \"value\": \"$status\",
                        \"short\": true
                    }, {
                        \"title\": \"Message\",
                        \"value\": \"$message\",
                        \"short\": false
                    }, {
                        \"title\": \"Time\",
                        \"value\": \"$(date)\",
                        \"short\": true
                    }]
                }]
            }" \
            "$WEBHOOK_URL" > /dev/null 2>&1
    fi
}

# Function to send email notification
send_email_notification() {
    local subject="$1"
    local body="$2"
    
    if [ -n "$EMAIL" ]; then
        echo "$body" | mail -s "$subject" "$EMAIL" 2>/dev/null || true
    fi
}

# Function to send desktop notification (macOS)
send_desktop_notification() {
    local title="$1"
    local message="$2"
    
    osascript -e "display notification \"$message\" with title \"$title\"" 2>/dev/null || true
}

# Function to notify deployment success
notify_success() {
    local flavor="$1"
    local track="$2"
    local build_time="$3"
    
    local message="🎉 $flavor successfully deployed to Play Store $track track!"
    local status="✅ SUCCESS"
    local color="good"
    
    log "Deployment success: $flavor -> $track"
    
    # Send all notifications
    send_slack_notification "$message" "$status" "$color"
    send_email_notification "School App Deployed: $flavor" "$message\n\nBuild Time: $build_time\nTrack: $track"
    send_desktop_notification "Deployment Success" "$flavor deployed to $track"
}

# Function to notify deployment failure
notify_failure() {
    local flavor="$1"
    local error="$2"
    
    local message="❌ $flavor deployment failed: $error"
    local status="❌ FAILED"
    local color="danger"
    
    log "Deployment failure: $flavor -> $error"
    
    # Send all notifications
    send_slack_notification "$message" "$status" "$color"
    send_email_notification "School App Deployment Failed: $flavor" "$message"
    send_desktop_notification "Deployment Failed" "$flavor deployment failed"
}

# Function to notify build start
notify_build_start() {
    local flavor="$1"
    local track="$2"
    
    local message="🚀 Starting deployment of $flavor to Play Store $track track..."
    local status="🔄 IN PROGRESS"
    local color="warning"
    
    log "Build started: $flavor -> $track"
    
    # Send all notifications
    send_slack_notification "$message" "$status" "$color"
    send_desktop_notification "Build Started" "$flavor deployment started"
}

# Function to send summary notification
send_summary() {
    local total="$1"
    local successful="$2"
    local failed="$3"
    local track="$4"
    local build_time="$5"
    
    local message="📊 Deployment Summary:\n• Total: $total\n• Successful: $successful\n• Failed: $failed\n• Track: $track\n• Build Time: $build_time"
    local status="📋 SUMMARY"
    local color="good"
    
    if [ "$failed" -gt 0 ]; then
        color="warning"
    fi
    
    log "Deployment summary: $successful/$total successful"
    
    # Send all notifications
    send_slack_notification "$message" "$status" "$color"
    send_email_notification "School App Deployment Summary" "$message"
    send_desktop_notification "Deployment Complete" "$successful/$total flavors deployed successfully"
}

# Function to setup notifications
setup_notifications() {
    print_info "Setting up deployment notifications..."
    
    # Create logs directory
    mkdir -p "$(dirname "$LOG_FILE")"
    
    # Ask for webhook URL
    if [ -z "$WEBHOOK_URL" ]; then
        echo "Enter your Slack/Discord webhook URL (or press Enter to skip):"
        read -r webhook_url
        if [ -n "$webhook_url" ]; then
            WEBHOOK_URL="$webhook_url"
            echo "WEBHOOK_URL=\"$webhook_url\"" >> ~/.zshrc
        fi
    fi
    
    # Ask for email
    if [ -z "$EMAIL" ]; then
        echo "Enter your email for notifications (or press Enter to skip):"
        read -r email
        if [ -n "$email" ]; then
            EMAIL="$email"
            echo "EMAIL=\"$email\"" >> ~/.zshrc
        fi
    fi
    
    print_status "Notification setup completed!"
    print_info "You'll receive notifications for:"
    print_info "  - Build start"
    print_info "  - Build success/failure"
    print_info "  - Deployment summary"
}

# Main function
main() {
    case "${1:-}" in
        --success)
            notify_success "$2" "$3" "$4"
            ;;
        --failure)
            notify_failure "$2" "$3"
            ;;
        --start)
            notify_build_start "$2" "$3"
            ;;
        --summary)
            send_summary "$2" "$3" "$4" "$5" "$6"
            ;;
        --setup)
            setup_notifications
            ;;
        --help)
            echo "Deployment Notification Script"
            echo ""
            echo "Usage: $0 [option] [args...]"
            echo ""
            echo "Options:"
            echo "  --success <flavor> <track> <build_time>  Notify successful deployment"
            echo "  --failure <flavor> <error>               Notify failed deployment"
            echo "  --start <flavor> <track>                 Notify build start"
            echo "  --summary <total> <successful> <failed> <track> <build_time>  Send summary"
            echo "  --setup                                  Setup notification preferences"
            echo "  --help                                   Show this help"
            ;;
        *)
            print_error "Invalid option. Use --help for usage information."
            exit 1
            ;;
    esac
}

main "$@"
