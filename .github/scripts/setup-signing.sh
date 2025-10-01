#!/bin/bash

# Script to setup signing configuration for different flavors
# Usage: ./setup-signing.sh <flavor>

set -e

FLAVOR=$1

if [ -z "$FLAVOR" ]; then
    echo "Error: Flavor name is required"
    echo "Usage: $0 <flavor>"
    exit 1
fi

# Load flavor configuration
CONFIG_FILE=".github/flavor-config.json"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Configuration file not found: $CONFIG_FILE"
    exit 1
fi

# Extract flavor configuration using jq
KEY_FILE=$(jq -r ".flavors.$FLAVOR.key_file" "$CONFIG_FILE")
KEY_ALIAS=$(jq -r ".flavors.$FLAVOR.key_alias" "$CONFIG_FILE")

if [ "$KEY_FILE" = "null" ] || [ "$KEY_ALIAS" = "null" ]; then
    echo "Error: Flavor '$FLAVOR' not found in configuration"
    exit 1
fi

echo "Setting up signing for flavor: $FLAVOR"
echo "Key file: $KEY_FILE"
echo "Key alias: $KEY_ALIAS"

# Create key.properties file
cat > android/key.properties << EOF
storePassword=${{ secrets[format('{0}_STORE_PASSWORD', matrix.flavor)] }}
keyAlias=$KEY_ALIAS
keyPassword=${{ secrets[format('{0}_KEY_PASSWORD', matrix.flavor)] }}
storeFile=../$KEY_FILE
EOF

# Decode the keystore file from secrets
echo "Decoding keystore file..."
echo "${{ secrets[format('{0}_KEYSTORE_BASE64', matrix.flavor)] }}" | base64 --decode > android/$KEY_FILE
chmod 600 android/$KEY_FILE

echo "Signing setup completed for $FLAVOR"

