#!/bin/bash

# Setup Git Hooks for Auto CI/CD
# This script sets up automatic builds when code is pulled

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

# Configuration
PROJECT_DIR="$(pwd)"
HOOK_DIR="$PROJECT_DIR/.git/hooks"
LOG_FILE="logs/git-hooks.log"

print_info "Setting up Git hooks for auto CI/CD..."

# Create logs directory
mkdir -p "$(dirname "$LOG_FILE")"

# Create post-merge hook (runs after git pull)
cat > "$HOOK_DIR/post-merge" << 'EOF'
#!/bin/bash

# Post-merge hook for auto CI/CD
# Runs after git pull to trigger builds

set -e

PROJECT_DIR="$(git rev-parse --show-toplevel)"
LOG_FILE="$PROJECT_DIR/logs/git-hooks.log"

# Function to log with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "Post-merge hook triggered"

# Check if we're on main branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "main" ]; then
    log "Not on main branch ($CURRENT_BRANCH), skipping build"
    exit 0
fi

# Check if there are actual changes
if git diff HEAD~1 HEAD --quiet; then
    log "No changes detected, skipping build"
    exit 0
fi

log "Changes detected on main branch, triggering build..."

# Change to project directory
cd "$PROJECT_DIR"

# Run the CI/CD pipeline
if [ -f "./local-cicd.sh" ]; then
    log "Running local CI/CD pipeline..."
    if ./local-cicd.sh; then
        log "Build completed successfully"
    else
        log "Build failed"
    fi
else
    log "local-cicd.sh not found, running quick build instead..."
    if [ -f "./quick-build.sh" ]; then
        ./quick-build.sh pace gaes cbsa
    else
        log "No build scripts found"
    fi
fi

log "Post-merge hook completed"
EOF

# Make hook executable
chmod +x "$HOOK_DIR/post-merge"

# Create post-checkout hook (runs after git checkout)
cat > "$HOOK_DIR/post-checkout" << 'EOF'
#!/bin/bash

# Post-checkout hook for auto CI/CD
# Runs after git checkout to trigger builds

set -e

PROJECT_DIR="$(git rev-parse --show-toplevel)"
LOG_FILE="$PROJECT_DIR/logs/git-hooks.log"

# Function to log with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Only run on branch checkout (not file checkout)
if [ "$3" = "1" ]; then
    log "Post-checkout hook triggered (branch checkout)"
    
    # Check if we're on main branch
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    if [ "$CURRENT_BRANCH" = "main" ]; then
        log "Switched to main branch, triggering build..."
        
        # Change to project directory
        cd "$PROJECT_DIR"
        
        # Run quick build
        if [ -f "./quick-build.sh" ]; then
            log "Running quick build..."
            ./quick-build.sh pace gaes cbsa
        fi
    fi
fi
EOF

# Make hook executable
chmod +x "$HOOK_DIR/post-checkout"

# Create a simple pull script
cat > "auto-pull.sh" << 'EOF'
#!/bin/bash

# Auto Pull Script with Build Trigger
# Use this instead of regular git pull

set -e

echo "🔄 Pulling latest changes and triggering build..."

# Pull changes
git pull origin main

# The post-merge hook will automatically trigger the build
echo "✅ Pull completed, build should be running..."
EOF

chmod +x auto-pull.sh

print_status "Git hooks installed successfully!"
print_info "Hooks created:"
print_info "  - post-merge: Runs after git pull"
print_info "  - post-checkout: Runs after git checkout"
print_info "  - auto-pull.sh: Use this instead of git pull"

print_info ""
print_info "Usage:"
print_info "  Instead of: git pull origin main"
print_info "  Use: ./auto-pull.sh"
print_info ""
print_info "Or just use regular git pull - the hooks will trigger automatically!"

print_status "Setup complete! 🎉"
