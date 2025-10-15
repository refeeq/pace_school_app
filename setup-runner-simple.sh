#!/bin/bash

# Simple GitHub Runner Setup
# Run this on your AWS Mac machine

set -e

echo "🚀 Setting up GitHub self-hosted runner..."

# Clean up old files
echo "🧹 Cleaning up old files..."
rm -rf actions-runner-osx-x64-2.311.0.tar.gz
rm -rf _diag .runner .credentials .credentials_rsaparams .token

# Download runner
echo "📥 Downloading runner..."
curl -o actions-runner-osx-x64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-osx-x64-2.311.0.tar.gz

# Extract
echo "📦 Extracting runner..."
tar xzf ./actions-runner-osx-x64-2.311.0.tar.gz

# Get token
echo ""
echo "🔑 Get your registration token:"
echo "1. Go to: https://github.com/hashiqvh/school_app/settings/actions/runners"
echo "2. Click 'New self-hosted runner'"
echo "3. Select 'macOS'"
echo "4. Copy the token"
echo ""
read -p "Enter your registration token: " TOKEN

# Configure with proper labels for auto-deploy workflow
echo "⚙️  Configuring runner with labels..."
./config.sh --url https://github.com/hashiqvh/school_app --token "$TOKEN" --labels "self-hosted,macos,aws" --name "aws-mac-runner"

echo "✅ Runner configured successfully!"
echo ""
echo "🚀 Starting runner..."
echo "Press Ctrl+C to stop"
./run.sh
