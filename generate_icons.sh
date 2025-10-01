#!/bin/bash

# Script to generate launcher icons for all flavors
# Make sure Flutter is in your PATH before running this script

echo "🚀 Generating launcher icons for all flavors..."

# Install dependencies
echo "📦 Installing dependencies..."
flutter pub get

# Generate default launcher icon
echo "🎨 Generating default launcher icon..."
dart run flutter_launcher_icons

# Generate launcher icons for each flavor
echo "🎨 Generating launcher icon for PACE INTL..."
dart run flutter_launcher_icons -f flutter_launcher_icons-pace.yaml

echo "🎨 Generating launcher icon for PACE IISS..."
dart run flutter_launcher_icons -f flutter_launcher_icons-iiss.yaml

echo "🎨 Generating launcher icon for PACE GAES..."
dart run flutter_launcher_icons -f flutter_launcher_icons-gaes.yaml

echo "🎨 Generating launcher icon for CBS Abudhabi..."
dart run flutter_launcher_icons -f flutter_launcher_icons-cbsa.yaml

echo "🎨 Generating launcher icon for DPS Ajman..."
dart run flutter_launcher_icons -f flutter_launcher_icons-dpsa.yaml

echo "🎨 Generating launcher icon for PACE PMBS..."
dart run flutter_launcher_icons -f flutter_launcher_icons-pmbs.yaml

echo "🎨 Generating launcher icon for PACE PCBS..."
dart run flutter_launcher_icons -f flutter_launcher_icons-pcbs.yaml

echo "🎨 Generating launcher icon for PACE PBSS..."
dart run flutter_launcher_icons -f flutter_launcher_icons-pbss.yaml

echo "🎨 Generating launcher icon for Springfield..."
dart run flutter_launcher_icons -f flutter_launcher_icons-sisd.yaml

echo "🎨 Generating launcher icon for DEMO..."
dart run flutter_launcher_icons -f flutter_launcher_icons-demo.yaml

echo "✅ All launcher icons generated successfully!"
echo ""
echo "📱 You can now build your app with different flavors:"
echo "   flutter build apk --flavor pace"
echo "   flutter build apk --flavor iiss"
echo "   flutter build apk --flavor gaes"
echo "   flutter build apk --flavor cbsa"
echo "   flutter build apk --flavor dpsa"
echo "   flutter build apk --flavor pmbs"
echo "   flutter build apk --flavor pcbs"
echo "   flutter build apk --flavor pbss"
echo "   flutter build apk --flavor sisd"
echo "   flutter build apk --flavor demo"
