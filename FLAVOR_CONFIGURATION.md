# Flavor Configuration Guide

This document explains how flavors are configured for both Android and iOS platforms in this Flutter project. Flavors allow you to build multiple variants of the same app with different configurations (app names, bundle IDs, Firebase configs, etc.) from a single codebase.

## Table of Contents

- [Overview](#overview)
- [Available Flavors](#available-flavors)
- [Android Configuration](#android-configuration)
- [iOS Configuration](#ios-configuration)
- [Flutter/Dart Configuration](#flutterdart-configuration)
- [Adding a New Flavor](#adding-a-new-flavor)
- [Building for Different Flavors](#building-for-different-flavors)
- [Troubleshooting](#troubleshooting)

---

## Overview

This project supports **10 flavors** representing different schools:

### ⚠️ Critical iOS Build Requirement

**For iOS builds to work correctly, the Firebase configuration must be properly set up:**

1. **Source Files:** Flavor-specific `GoogleService-Info.plist` files are located in:
   - `ios/config/<flavor>/GoogleService-Info.plist`

2. **Build Process:** A build script automatically copies the correct file during build from:
   - Source: `ios/config/<flavor>/GoogleService-Info.plist`
   - Destination: App bundle (automatically handled)

3. **Manual Testing:** For testing/development, you may need to manually copy:
   ```bash
   cp ios/config/<flavor>/GoogleService-Info.plist ios/Runner/GoogleService-Info.plist
   ```

4. **Build Failure:** If the flavor-specific file doesn't exist, the build will fail with an error.

**See [iOS Firebase Configuration](#3-firebase-configuration-ios) section for detailed information.**
- `pace` - PACE International School
- `gaes` - Gulf Asian English School
- `iiss` - India International School
- `cbsa` - Creative British School Abu Dhabi
- `dpsa` - Delhi Private School Ajman
- `pbss` - PACE British School
- `pcbs` - PACE Creative British School
- `pmbs` - PACE Modern British School
- `sisd` - Springfield International School
- `demo` - Demo/Development flavor

Each flavor has:
- Unique **Application ID / Bundle Identifier**
- Unique **App Display Name**
- Unique **Firebase Configuration**
- Unique **App Icon** (configured via launcher icons)
- Unique **Signing Keys** (Android)

---

## Available Flavors

| Flavor | Package Name (Android) | Bundle ID (iOS) | App Name | Key File (Android) |
|--------|------------------------|-----------------|----------|-------------------|
| **pace** | `com.pacesharjah.schoolapp` | `com.pacesharjah.schoolapp` | PACE INTL | `pace_key.jks` |
| **gaes** | `com.gaes.schoolapp` | `com.gaes.schoolapp` | PACE GAES | `gaes.key` |
| **cbsa** | `com.cbsa.schoolapp` | `com.cbsa.schoolapp` | CBS Abudhabi | `pace_key.jks` |
| **dpsa** | `com.dpsa.schoolapp` | `com.dpsa.schoolapp` | DPS Ajman | `pace_key.jks` |
| **iiss** | `com.iiss.schoolapp` | `com.iiss.schoolapp` | PACE IISS | `pace_key.jks` |
| **pbss** | `com.pbss.schoolapp` | `com.pbss.schoolapp` | PACE PBSS | `pace_key.jks` |
| **pcbs** | `com.pcbs.schoolapp` | `com.pcbs.schoolapp` | PACE PCBS | `pace_key.jks` |
| **pmbs** | `com.pmbs.schoolapp` | `com.pmbs.schoolapp` | PACE PMBS | `pace_key.jks` |
| **sisd** | `com.sisd.schoolapp` | `com.sisd.schoolapp` | Springfield | `pace_key.jks` |
| **demo** | `com.demo.schoolapp` | `com.demo.schoolapp` | DEMO | `pace_key.jks` |

---

## Android Configuration

### 1. Build Configuration File

**Location:** `android/app/build.gradle.kts`

The Android flavors are defined using Gradle's `productFlavors` block:

```kotlin
android {
    flavorDimensions += "default"
    
    productFlavors {
        create("pace") {
            dimension = "default"
            applicationId = "com.pacesharjah.schoolapp"
            resValue("string", "app_name", "PACE INTL")
        }
        // ... other flavors
    }
}
```

**Key Points:**
- All flavors share the same `dimension` ("default")
- Each flavor has a unique `applicationId` (package name)
- `resValue` sets the app name that appears on the device
- The `applicationId` must match the bundle identifier used in Firebase

### 2. Signing Configuration

**Location:** `android/app/build.gradle.kts`

Signing is configured via `key.properties` file:

```kotlin
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

signingConfigs {
    create("release") {
        keyAlias = keystoreProperties["keyAlias"] as String?
        keyPassword = keystoreProperties["keyPassword"] as String?
        storeFile = keystoreProperties["storeFile"]?.let { file(it) }
        storePassword = keystoreProperties["storePassword"] as String?
    }
}
```

**Key Files:**
- `android/key.properties` - Contains signing credentials (NOT in version control)
- `android/pace_key.jks` - Keystore file for most flavors
- `android/gaes.key` - Keystore file for GAES flavor

### 3. App Icons

**Location:** Root directory

Each flavor has its own icon configuration file:
- `flutter_launcher_icons-pace.yaml`
- `flutter_launcher_icons-gaes.yaml`
- `flutter_launcher_icons-cbsa.yaml`
- etc.

Generate icons using:
```bash
flutter pub run flutter_launcher_icons:main -f flutter_launcher_icons-<flavor>.yaml
```

### 4. Firebase Configuration (Android)

**Location:** `android/app/google-services.json`

Firebase configuration is typically handled at build time. The `google-services.json` file should be placed in `android/app/` directory. However, for multi-flavor setups, you may need flavor-specific configurations.

---

## iOS Configuration

### 1. Xcode Project Configuration

**Location:** `ios/Runner.xcodeproj/project.pbxproj`

iOS uses **Build Configurations** and **Schemes** to manage flavors. Each flavor has its own build configuration:

- `Debug-<flavor>` (e.g., `Debug-pace`, `Debug-gaes`)
- `Release-<flavor>` (e.g., `Release-pace`, `Release-gaes`)
- `Profile-<flavor>` (e.g., `Profile-pace`, `Profile-gaes`)

**Key Settings per Configuration:**
```xcode
PRODUCT_BUNDLE_IDENTIFIER = com.pacesharjah.schoolapp;
INFOPLIST_KEY_CFBundleDisplayName = "PACE INTL";
FLUTTER_TARGET = lib/schools/pace/pace_main.dart;
ASSETCATALOG_COMPILER_APPICON_NAME = "AppIcon-pace";
```

### 2. Build Schemes

**Location:** `ios/Runner.xcodeproj/xcshareddata/xcschemes/`

Each flavor has its own Xcode scheme:
- `pace.xcscheme`
- `gaes.xcscheme`
- `cbsa.xcscheme`
- etc.

Schemes define which build configuration to use for Debug, Release, and Profile builds.

### 3. Firebase Configuration (iOS)

**⚠️ CRITICAL: iOS Firebase Configuration Setup**

For iOS builds to work correctly, the flavor-specific `GoogleService-Info.plist` must be properly configured and copied during the build process.

**File Locations:**
- **Source (Flavor-specific):** `ios/config/<flavor>/GoogleService-Info.plist`
  - `ios/config/pace/GoogleService-Info.plist`
  - `ios/config/gaes/GoogleService-Info.plist`
  - `ios/config/cbsa/GoogleService-Info.plist`
  - etc.

- **Destination (Runner directory):** `ios/Runner/GoogleService-Info.plist`
  - This file gets replaced during build with the flavor-specific version

**Build Script (Automatic Copy):**
A build phase script in Xcode automatically copies the appropriate `GoogleService-Info.plist` based on the build configuration:

```bash
# Extract flavor from build configuration name
# Example: "Debug-pace" → extracts "pace"
if [[ $CONFIGURATION =~ -([^-]*)$ ]]; then
    environment=${BASH_REMATCH[1]}
fi

# Source file: flavor-specific GoogleService-Info.plist
GOOGLESERVICE_INFO_PLIST=GoogleService-Info.plist
GOOGLESERVICE_INFO_FILE=${PROJECT_DIR}/config/${environment}/${GOOGLESERVICE_INFO_PLIST}

# Verify source file exists
if [ ! -f $GOOGLESERVICE_INFO_FILE ]; then
    echo "No GoogleService-Info.plist found. Please ensure it's in the proper directory."
    exit 1
fi

# Destination: Copy to the built app bundle
PLIST_DESTINATION=${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app
cp "${GOOGLESERVICE_INFO_FILE}" "${PLIST_DESTINATION}"
```

**Location in Xcode:** 
- `Runner.xcodeproj` → Build Phases → "Copy GoogleServices-Info.plist"
- This script runs **before** the "Copy Bundle Resources" phase

**Important Notes:**
1. **For Testing/Development:** The script automatically handles copying the correct file during build
2. **Manual Testing:** If you need to test a specific flavor manually:
   ```bash
   # Copy flavor-specific file to Runner directory
   cp ios/config/pace/GoogleService-Info.plist ios/Runner/GoogleService-Info.plist
   ```
3. **Build Requirement:** The build will **fail** if the flavor-specific `GoogleService-Info.plist` doesn't exist in `ios/config/<flavor>/`
4. **File Structure:** Ensure each flavor has its Firebase config in `ios/config/<flavor>/GoogleService-Info.plist`

**Troubleshooting:**
- If Firebase doesn't initialize: Check that the correct `GoogleService-Info.plist` is in `ios/config/<flavor>/`
- If build fails: Verify the build script can find the file at `${PROJECT_DIR}/config/${environment}/GoogleService-Info.plist`
- For manual testing: Replace `ios/Runner/GoogleService-Info.plist` with the flavor-specific version before running

### 4. App Icons (iOS)

**Location:** `ios/Runner/Assets.xcassets/`

Each flavor has its own app icon set:
- `AppIcon-pace`
- `AppIcon-gaes`
- `AppIcon-cbsa`
- etc.

Configured via `ASSETCATALOG_COMPILER_APPICON_NAME` in build settings.

### 5. Podfile Configuration

**Location:** `ios/Podfile`

The Podfile sets the minimum iOS deployment target:

```ruby
platform :ios, '15.0'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end
```

---

## Flutter/Dart Configuration

### 1. Environment Setup

**Location:** `lib/app.dart`

The `AppEnivrornment` class manages flavor-specific configuration:

```dart
abstract class AppEnivrornment {
  static late String appName;
  static late String bundleName;
  static late String firbaseName;
  static late String appFullName;
  static late String appImageName;
  static late String url;
  static late FirebaseOptions firebaseOptions;
  
  static void setupEnv(AppEnvironmentNames environmentNames) {
    switch (environmentNames) {
      case AppEnvironmentNames.pace:
        bundleName = "com.pacesharjah.schoolapp";
        appName = "PACE INTL";
        firebaseOptions = PaceDefaultFirebaseOptions.currentPlatform;
        // ... other configs
        break;
      // ... other flavors
    }
  }
}
```

### 2. Flavor Entry Points

**Location:** `lib/schools/<flavor>/<flavor>_main.dart`

Each flavor has its own entry point that:
1. Sets up the environment
2. Initializes Flutter bindings
3. Initializes Firebase and services
4. Runs the app

**Example:** `lib/schools/pace/pace_main.dart`
```dart
void main() async {
  AppEnivrornment.setupEnv(AppEnvironmentNames.pace);
  WidgetsFlutterBinding.ensureInitialized();
  await initilization();
  runApp(const MyApp());
}
```

### 3. Firebase Options

**Location:** `lib/schools/<flavor>/<flavor>_firebase_options.dart`

Each flavor has auto-generated Firebase options:
- `lib/schools/pace/pace_firebase_options.dart`
- `lib/schools/gaes/gaes_firebase_options.dart`
- etc.

These are generated using:
```bash
flutterfire configure --project=<firebase-project-id>
```

---

## Adding a New Flavor

### Step 1: Android Configuration

1. **Add to `android/app/build.gradle.kts`:**
```kotlin
productFlavors {
    create("newflavor") {
        dimension = "default"
        applicationId = "com.newflavor.schoolapp"
        resValue("string", "app_name", "New Flavor Name")
    }
}
```

2. **Create signing configuration:**
   - Add keystore file to `android/` directory
   - Update `android/key.properties` with signing credentials

3. **Create icon configuration:**
   - Create `flutter_launcher_icons-newflavor.yaml`
   - Generate icons: `flutter pub run flutter_launcher_icons:main -f flutter_launcher_icons-newflavor.yaml`

### Step 2: iOS Configuration

1. **Add Build Configurations in Xcode:**
   - Open `ios/Runner.xcodeproj` in Xcode
   - Go to Project → Info → Configurations
   - Duplicate existing Debug/Release/Profile configurations
   - Rename to `Debug-newflavor`, `Release-newflavor`, `Profile-newflavor`
   - Set:
     - `PRODUCT_BUNDLE_IDENTIFIER` = `com.newflavor.schoolapp`
     - `INFOPLIST_KEY_CFBundleDisplayName` = "New Flavor Name"
     - `FLUTTER_TARGET` = `lib/schools/newflavor/newflavor_main.dart`
     - `ASSETCATALOG_COMPILER_APPICON_NAME` = `AppIcon-newflavor`

2. **Create Xcode Scheme:**
   - Product → Scheme → Manage Schemes
   - Duplicate existing scheme
   - Rename to `newflavor`
   - Set build configurations:
     - Debug: `Debug-newflavor`
     - Release: `Release-newflavor`
     - Profile: `Profile-newflavor`

3. **Add Firebase Configuration:**
   - **iOS:** Create `ios/config/newflavor/GoogleService-Info.plist`
     - Download from Firebase Console
     - Place in `ios/config/newflavor/` directory
     - The build script will automatically copy this during build
   - **Android:** Add `google-services.json` to `android/app/` (if needed)
   - **Dart:** Generate Firebase options:
     ```bash
     flutterfire configure --project=<newflavor-project-id> --out=lib/schools/newflavor/
     ```

4. **Add App Icon:**
   - Add `AppIcon-newflavor` to `ios/Runner/Assets.xcassets/`

### Step 3: Flutter/Dart Configuration

1. **Add to `lib/app.dart`:**
```dart
enum AppEnvironmentNames {
  pace, gaes, iiss, cbsa, dpsa, pbss, pcbs, pmbs, sisd, demo, newflavor
}

static void setupEnv(AppEnvironmentNames environmentNames) {
  switch (environmentNames) {
    case AppEnvironmentNames.newflavor:
      bundleName = "com.newflavor.schoolapp";
      appName = "New Flavor Name";
      firebaseOptions = NewFlavorDefaultFirebaseOptions.currentPlatform;
      // ... other configs
      break;
  }
}
```

2. **Create entry point:**
   - Create `lib/schools/newflavor/newflavor_main.dart`
   ```dart
   void main() async {
     AppEnivrornment.setupEnv(AppEnvironmentNames.newflavor);
     WidgetsFlutterBinding.ensureInitialized();
     await initilization();
     runApp(const MyApp());
   }
   ```

3. **Generate Firebase Options:**
   ```bash
   flutterfire configure --project=<newflavor-project-id> --out=lib/schools/newflavor/
   ```

4. **Update CI/CD:**
   - Add to `.github/workflows/auto-deploy-playstore.yml` matrix
   - Add to `.github/flavor-config.json`

---

## Building for Different Flavors

### Android

**Debug Build:**
```bash
flutter build apk --flavor pace --target lib/schools/pace/pace_main.dart
flutter build appbundle --flavor pace --target lib/schools/pace/pace_main.dart --release
```

**Release Build:**
```bash
flutter build apk --release --flavor pace --target lib/schools/pace/pace_main.dart
flutter build appbundle --release --flavor pace --target lib/schools/pace/pace_main.dart
```

**Install on Device:**
```bash
flutter install --flavor pace --target lib/schools/pace/pace_main.dart
```

### iOS

**⚠️ IMPORTANT: Firebase Configuration for iOS Builds**

Before building for iOS, ensure the correct `GoogleService-Info.plist` is in place:

**Automatic (Recommended - Build Script):**
The build script automatically copies the flavor-specific file during build. Just ensure:
- `ios/config/<flavor>/GoogleService-Info.plist` exists for your flavor
- Build using the correct scheme/configuration

**Manual (For Testing/Development):**
If you need to manually set up for testing:
```bash
# Copy flavor-specific GoogleService-Info.plist to Runner directory
cp ios/config/pace/GoogleService-Info.plist ios/Runner/GoogleService-Info.plist

# Then build or run
flutter run --flavor pace --target lib/schools/pace/pace_main.dart
```

**Debug Build:**
```bash
flutter build ios --flavor pace --target lib/schools/pace/pace_main.dart --debug --no-codesign
```

**Release Build:**
```bash
flutter build ios --flavor pace --target lib/schools/pace/pace_main.dart --release
```

**Using Xcode:**
1. Open `ios/Runner.xcworkspace` (NOT `.xcodeproj`)
2. Select scheme: `pace` (or desired flavor)
3. Select build configuration: `Debug-pace`, `Release-pace`, or `Profile-pace`
4. **Verify Build Phase:** Check that "Copy GoogleServices-Info.plist" script is present
5. Build and run

**Archive for App Store:**
1. Select `Release-<flavor>` configuration
2. Product → Archive
3. Distribute App

**Testing Different Flavors:**
When switching between flavors for testing:
```bash
# Stop current app
# Copy the desired flavor's GoogleService-Info.plist
cp ios/config/<flavor>/GoogleService-Info.plist ios/Runner/GoogleService-Info.plist

# Run with the new flavor
flutter run --flavor <flavor> --target lib/schools/<flavor>/<flavor>_main.dart
```

### Running in Development

**Android:**
```bash
flutter run --flavor pace --target lib/schools/pace/pace_main.dart
```

**iOS:**
```bash
flutter run --flavor pace --target lib/schools/pace/pace_main.dart
```

---

## Troubleshooting

### Android Issues

**Problem:** Build fails with "Application ID mismatch"
- **Solution:** Ensure `applicationId` in `build.gradle.kts` matches Firebase project package name

**Problem:** Signing errors
- **Solution:** Verify `android/key.properties` exists and contains correct credentials
- Ensure keystore file exists in `android/` directory

**Problem:** App name not changing
- **Solution:** Check `resValue("string", "app_name", ...)` in build.gradle.kts
- Clear build: `flutter clean && flutter pub get`

### iOS Issues

**Problem:** "No GoogleService-Info.plist found"
- **Solution:** 
  - Ensure `ios/config/<flavor>/GoogleService-Info.plist` exists (NOT `lib/config/`)
  - Verify the build script path: `${PROJECT_DIR}/config/${environment}/GoogleService-Info.plist`
  - Check that the build configuration name matches the flavor (e.g., `Debug-pace` extracts `pace`)
  - For manual testing: Copy `ios/config/<flavor>/GoogleService-Info.plist` to `ios/Runner/GoogleService-Info.plist`

**Problem:** Firebase not working in iOS build
- **Solution:**
  - Verify the correct `GoogleService-Info.plist` is being copied during build
  - Check build logs for "Copy GoogleServices-Info.plist" script output
  - Ensure the file in `ios/config/<flavor>/` matches the bundle identifier
  - For testing: Manually replace `ios/Runner/GoogleService-Info.plist` with flavor-specific version

**Problem:** Wrong bundle identifier
- **Solution:** Check `PRODUCT_BUNDLE_IDENTIFIER` in Xcode build settings for the specific configuration

**Problem:** Pod install fails
- **Solution:** 
  ```bash
  cd ios
  rm -rf Pods Podfile.lock
  pod install
  ```

**Problem:** Scheme not found
- **Solution:** Ensure scheme is shared: Xcode → Product → Scheme → Manage Schemes → Check "Shared"

### General Issues

**Problem:** Firebase not initializing
- **Solution:** 
  - Verify Firebase options file exists for the flavor
  - Check `AppEnivrornment.setupEnv()` is called before Firebase initialization
  - Ensure correct `GoogleService-Info.plist` is being used

**Problem:** Wrong app icon
- **Solution:** 
  - Regenerate icons: `flutter pub run flutter_launcher_icons:main -f flutter_launcher_icons-<flavor>.yaml`
  - For iOS, verify `ASSETCATALOG_COMPILER_APPICON_NAME` in build settings

---

## Additional Resources

- [Flutter Flavors Documentation](https://docs.flutter.dev/deployment/flavors)
- [Android Product Flavors](https://developer.android.com/studio/build/build-variants)
- [Xcode Build Configurations](https://developer.apple.com/documentation/xcode/adding-a-build-configuration-file-to-your-project)
- [Firebase Multi-Project Setup](https://firebase.google.com/docs/flutter/setup)

---

## Notes

- Always use `Runner.xcworkspace` (not `.xcodeproj`) when opening iOS project in Xcode
- Keep `key.properties` and keystore files out of version control
- Each flavor should have its own Firebase project
- Test each flavor independently before deploying
- Update CI/CD workflows when adding new flavors

---

**Last Updated:** January 2025  
**Maintained By:** Development Team

