#!/bin/bash

# Complete Auto-Deploy Setup Script
# Sets up automatic Play Store deployment on AWS Mac

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
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

print_header() {
    echo -e "${PURPLE}🚀 $1${NC}"
}

# Configuration
PROJECT_DIR="$(pwd)"
GITHUB_REPO=""
AWS_MAC_IP=""

print_header "School App Auto-Deploy Setup"
echo "This script will set up automatic Play Store deployment on your AWS Mac machine."
echo ""

# Get GitHub repository URL
if [ -z "$GITHUB_REPO" ]; then
    echo "Enter your GitHub repository URL (e.g., https://github.com/username/school_app):"
    read -r github_repo
    GITHUB_REPO="$github_repo"
fi

# Get AWS Mac IP
if [ -z "$AWS_MAC_IP" ]; then
    echo "Enter your AWS Mac machine IP address:"
    read -r aws_ip
    AWS_MAC_IP="$aws_ip"
fi

print_info "Setting up auto-deploy for: $GITHUB_REPO"
print_info "AWS Mac IP: $AWS_MAC_IP"

# Step 1: Setup AWS Mac Machine
print_header "Step 1: Setting up AWS Mac Machine"

cat > setup-aws-mac.sh << 'EOF'
#!/bin/bash

# AWS Mac Setup Script
# Run this on your AWS Mac machine

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

print_header() {
    echo -e "${PURPLE}🚀 $1${NC}"
}

print_header "Setting up AWS Mac for Auto-Deploy"

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script must be run on macOS"
    exit 1
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed. Please install Flutter first."
    exit 1
fi

# Check if Android SDK is installed
if [ ! -d "$HOME/Library/Android/sdk" ]; then
    print_error "Android SDK is not installed. Please install Android Studio first."
    exit 1
fi

print_status "Flutter and Android SDK found"

# Clone repository
print_info "Cloning repository..."
if [ ! -d "school_app" ]; then
    git clone "$GITHUB_REPO" school_app
fi

cd school_app
git pull origin main

# Make scripts executable
chmod +x *.sh

# Setup environment variables
print_info "Setting up environment variables..."
cat >> ~/.zshrc << 'ENVEOF'

# School App Auto-Deploy Environment
export ANDROID_HOME=$HOME/Library/Android/sdk
export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools
ENVEOF

# Reload shell
source ~/.zshrc

# Setup git hooks for auto-pull
print_info "Setting up git hooks..."
./setup-git-hooks.sh

# Setup notifications
print_info "Setting up notifications..."
./notify-deployment.sh --setup

# Test build
print_info "Testing build..."
if ./quick-build.sh pace; then
    print_status "Test build successful!"
else
    print_warning "Test build failed, but setup continues..."
fi

print_status "AWS Mac setup completed!"
print_info "Your AWS Mac is now ready for auto-deploy"
print_info "Every time you push to GitHub, it will automatically:"
print_info "  - Pull the latest code"
print_info "  - Build all flavors"
print_info "  - Deploy to Play Store"
print_info "  - Send notifications"
EOF

chmod +x setup-aws-mac.sh

print_status "AWS Mac setup script created: setup-aws-mac.sh"

# Step 2: Setup GitHub Secrets
print_header "Step 2: GitHub Secrets Setup"

cat > github-secrets-setup.md << EOF
# GitHub Secrets Setup

You need to add these secrets to your GitHub repository:

## Required Secrets:

1. **PACE_STORE_PASSWORD** - Password for pace_key.jks
2. **PACE_KEY_PASSWORD** - Key password for pace_key.jks  
3. **PACE_KEYSTORE_BASE64** - Base64 encoded pace_key.jks file
4. **GAES_STORE_PASSWORD** - Password for gaes.key
5. **GAES_KEY_PASSWORD** - Key password for gaes.key
6. **GAES_KEYSTORE_BASE64** - Base64 encoded gaes.key file
7. **GOOGLE_PLAY_SERVICE_ACCOUNT_JSON** - Google Play Console service account JSON

## How to add secrets:

1. Go to your GitHub repository
2. Click Settings > Secrets and variables > Actions
3. Click "New repository secret"
4. Add each secret with the exact name above

## How to get base64 encoded keystores:

\`\`\`bash
# For pace_key.jks
base64 -i pace_key.jks | pbcopy

# For gaes.key  
base64 -i gaes.key | pbcopy
\`\`\`

## Google Play Console Setup:

1. Go to Google Play Console
2. Setup > API access
3. Create a service account
4. Download the JSON key file
5. Add the JSON content as GOOGLE_PLAY_SERVICE_ACCOUNT_JSON secret
EOF

print_status "GitHub secrets guide created: github-secrets-setup.md"

# Step 3: Setup Webhook (Optional)
print_header "Step 3: Webhook Setup (Optional)"

cat > webhook-setup.md << EOF
# Webhook Setup (Optional)

For real-time notifications, you can set up a webhook:

## Slack Webhook:

1. Go to https://api.slack.com/apps
2. Create a new app
3. Go to Incoming Webhooks
4. Create a webhook for your channel
5. Copy the webhook URL

## Discord Webhook:

1. Go to your Discord server
2. Server Settings > Integrations > Webhooks
3. Create a new webhook
4. Copy the webhook URL

## Add webhook to AWS Mac:

Edit ~/.zshrc and add:
\`\`\`bash
export WEBHOOK_URL="your_webhook_url_here"
\`\`\`
EOF

print_status "Webhook setup guide created: webhook-setup.md"

# Step 4: Create deployment instructions
print_header "Step 4: Deployment Instructions"

cat > DEPLOYMENT-INSTRUCTIONS.md << EOF
# 🚀 Auto-Deploy Setup Instructions

## Quick Start:

### 1. Setup AWS Mac Machine:
\`\`\`bash
# SSH into your AWS Mac
ssh ec2-user@$AWS_MAC_IP

# Run the setup script
curl -sSL https://raw.githubusercontent.com/your-username/school_app/main/setup-aws-mac.sh | bash
\`\`\`

### 2. Add GitHub Secrets:
- Go to your GitHub repository
- Settings > Secrets and variables > Actions
- Add all required secrets (see github-secrets-setup.md)

### 3. Test the Pipeline:
\`\`\`bash
# Make a test change and push
echo "// Test auto-deploy" >> lib/main.dart
git add .
git commit -m "Test auto-deploy"
git push origin main
\`\`\`

## What Happens Automatically:

1. **Push to GitHub** → Triggers workflow
2. **AWS Mac pulls code** → Builds all flavors
3. **Uploads to Play Store** → Internal track by default
4. **Sends notifications** → Slack/Discord/Email

## Manual Deployment:

You can also trigger manual deployments:
- Go to Actions tab in GitHub
- Click "Auto Deploy to Play Store"
- Click "Run workflow"
- Choose track (internal/alpha/beta/production)

## Monitoring:

- Check GitHub Actions for build status
- Check ~/playstore-deployments/ on AWS Mac for artifacts
- Check logs/ directory for detailed logs

## Troubleshooting:

- Check GitHub Actions logs
- Check AWS Mac logs: tail -f logs/git-hooks.log
- Verify secrets are correct
- Check Play Store Console for uploads
EOF

print_status "Deployment instructions created: DEPLOYMENT-INSTRUCTIONS.md"

# Step 5: Create monitoring script
print_header "Step 5: Creating Monitoring Script"

cat > monitor-deployments.sh << 'EOF'
#!/bin/bash

# Deployment Monitoring Script
# Shows status of recent deployments

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

print_header() {
    echo -e "${PURPLE}📊 $1${NC}"
}

print_header "Deployment Status Monitor"

# Check recent deployments
echo "Recent deployments:"
if [ -d ~/playstore-deployments ]; then
    ls -la ~/playstore-deployments/ | head -10
else
    echo "No deployments found"
fi

echo ""
echo "Recent build logs:"
if [ -f logs/git-hooks.log ]; then
    tail -20 logs/git-hooks.log
else
    echo "No logs found"
fi

echo ""
echo "GitHub Actions status:"
if command -v gh &> /dev/null; then
    gh run list --limit 5
else
    echo "GitHub CLI not installed. Check GitHub Actions tab manually."
fi
EOF

chmod +x monitor-deployments.sh

print_status "Monitoring script created: monitor-deployments.sh"

# Final summary
print_header "Setup Complete! 🎉"

echo ""
print_info "Next steps:"
echo "1. Copy setup-aws-mac.sh to your AWS Mac machine"
echo "2. Run it on your AWS Mac: ./setup-aws-mac.sh"
echo "3. Add GitHub secrets (see github-secrets-setup.md)"
echo "4. Test with a push to GitHub"
echo ""
print_info "Files created:"
echo "  - setup-aws-mac.sh (run on AWS Mac)"
echo "  - github-secrets-setup.md (GitHub setup guide)"
echo "  - webhook-setup.md (optional notifications)"
echo "  - DEPLOYMENT-INSTRUCTIONS.md (complete guide)"
echo "  - monitor-deployments.sh (monitoring script)"
echo ""
print_status "Your auto-deploy pipeline is ready! 🚀"
