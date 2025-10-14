#!/bin/bash

# Setup Cron Job for Automated CI/CD
# This script sets up automated builds on your self-hosted machine

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

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CICD_SCRIPT="$SCRIPT_DIR/local-cicd.sh"
QUICK_BUILD_SCRIPT="$SCRIPT_DIR/quick-build.sh"

# Function to setup cron job
setup_cron() {
    local schedule=$1
    local job_type=$2
    
    print_status "Setting up cron job..."
    
    # Create cron job entry
    local cron_entry=""
    if [ "$job_type" = "full" ]; then
        cron_entry="$schedule cd $SCRIPT_DIR && $CICD_SCRIPT >> logs/cron.log 2>&1"
    else
        cron_entry="$schedule cd $SCRIPT_DIR && $QUICK_BUILD_SCRIPT pace gaes cbsa >> logs/cron.log 2>&1"
    fi
    
    # Add to crontab
    (crontab -l 2>/dev/null; echo "$cron_entry") | crontab -
    
    print_status "Cron job added: $cron_entry"
}

# Function to show available schedules
show_schedules() {
    echo "Available cron schedules:"
    echo "1. Every hour: '0 * * * *'"
    echo "2. Every 6 hours: '0 */6 * * *'"
    echo "3. Every day at 2 AM: '0 2 * * *'"
    echo "4. Every weekday at 9 AM: '0 9 * * 1-5'"
    echo "5. Every Sunday at midnight: '0 0 * * 0'"
    echo "6. Custom: Enter your own cron expression"
}

# Main function
main() {
    echo "🕐 Cron Job Setup for School App CI/CD"
    echo "======================================"
    
    # Check if scripts exist
    if [ ! -f "$CICD_SCRIPT" ]; then
        print_error "local-cicd.sh not found in $SCRIPT_DIR"
        exit 1
    fi
    
    if [ ! -f "$QUICK_BUILD_SCRIPT" ]; then
        print_error "quick-build.sh not found in $SCRIPT_DIR"
        exit 1
    fi
    
    # Make scripts executable
    chmod +x "$CICD_SCRIPT"
    chmod +x "$QUICK_BUILD_SCRIPT"
    
    # Create logs directory
    mkdir -p logs
    
    print_status "Scripts found and made executable"
    
    # Show current crontab
    echo ""
    echo "Current crontab:"
    crontab -l 2>/dev/null || echo "No crontab found"
    
    echo ""
    show_schedules
    
    echo ""
    read -p "Enter cron schedule (e.g., '0 2 * * *' for daily at 2 AM): " schedule
    
    if [ -z "$schedule" ]; then
        print_error "No schedule provided"
        exit 1
    fi
    
    echo ""
    echo "Choose build type:"
    echo "1. Full CI/CD (all flavors, tests, analysis)"
    echo "2. Quick build (pace, gaes, cbsa only)"
    read -p "Enter choice (1 or 2): " choice
    
    case $choice in
        1)
            setup_cron "$schedule" "full"
            print_status "Full CI/CD cron job setup completed"
            ;;
        2)
            setup_cron "$schedule" "quick"
            print_status "Quick build cron job setup completed"
            ;;
        *)
            print_error "Invalid choice"
            exit 1
            ;;
    esac
    
    echo ""
    print_status "Cron job setup completed!"
    echo ""
    echo "To view your crontab: crontab -l"
    echo "To edit your crontab: crontab -e"
    echo "To remove all crontabs: crontab -r"
    echo ""
    echo "Logs will be saved to: logs/cron.log"
    echo "Build artifacts will be saved to: build-artifacts/"
}

main "$@"
