#!/bin/bash

echo "🚀 Testing build script..."
echo "Current directory: $(pwd)"
echo "Flutter version: $(flutter --version 2>/dev/null || echo 'Flutter not found')"
echo "Available flavors:"
ls -la lib/schools/ 2>/dev/null || echo "No schools directory found"

echo ""
echo "Testing pace flavor build..."
if [ -f "lib/schools/pace/pace_main.dart" ]; then
    echo "✅ pace_main.dart found"
    flutter pub get
    flutter build apk --release --flavor pace --target lib/schools/pace/pace_main.dart
    echo "✅ Build completed!"
else
    echo "❌ pace_main.dart not found"
fi
