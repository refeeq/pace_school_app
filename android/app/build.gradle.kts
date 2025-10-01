import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load keystore properties
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.example.school_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    flavorDimensions += "default"

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.school_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    productFlavors {
        create("pace") {
            dimension = "default"
            applicationId = "com.pacesharjah.schoolapp"
            resValue("string", "app_name", "PACE INTL")
        }
        create("iiss") {
            dimension = "default"
            applicationId = "com.iiss.schoolapp"
            resValue("string", "app_name", "PACE IISS")
        }
        create("gaes") {
            dimension = "default"
            applicationId = "com.gaes.schoolapp"
            resValue("string", "app_name", "PACE GAES")
        }
        create("cbsa") {
            dimension = "default"
            applicationId = "com.cbsa.schoolapp"
            resValue("string", "app_name", "CBS Abudhabi")
        }
        create("dpsa") {
            dimension = "default"
            applicationId = "com.dpsa.schoolapp"
            resValue("string", "app_name", "DPS Ajman")
        }
        create("pmbs") {
            dimension = "default"
            applicationId = "com.pmbs.schoolapp"
            resValue("string", "app_name", "PACE PMBS")
        }
        create("pcbs") {
            dimension = "default"
            applicationId = "com.pcbs.schoolapp"
            resValue("string", "app_name", "PACE PCBS")
        }
        create("pbss") {
            dimension = "default"
            applicationId = "com.pbss.schoolapp"
            resValue("string", "app_name", "PACE PBSS")
        }
        create("sisd") {
            dimension = "default"
            applicationId = "com.sisd.schoolapp"
            resValue("string", "app_name", "Springfield")
        }
        create("demo") {
            dimension = "default"
            applicationId = "com.demo.schoolapp"
            resValue("string", "app_name", "DEMO")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
            // proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ... other dependencies
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4") // Or a newer version
}