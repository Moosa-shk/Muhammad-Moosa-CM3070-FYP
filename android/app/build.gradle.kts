plugins {
    id("com.android.application")

    // ✅ Firebase Google Services plugin
    id("com.google.gms.google-services")

    // ✅ Kotlin
    id("kotlin-android")

    // ✅ Flutter plugin (ALWAYS last)
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.disaster_app_ui_new"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // ✅ Recommended for Flutter + modern plugins
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17

        // ✅ REQUIRED by flutter_local_notifications (and many libs)
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // ✅ MUST MATCH your google-services.json!
        applicationId = "com.example.disaster_app_ui_new"

        // ✅ flutter_local_notifications + desugaring works best with minSdk 21+
        minSdk = maxOf(21, flutter.minSdkVersion)

        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // ✅ Still using debug signing (fine for development)
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

dependencies {
    // ✅ REQUIRED for coreLibraryDesugaringEnabled
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

flutter {
    source = "../.."
}