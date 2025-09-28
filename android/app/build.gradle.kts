// APP-LEVEL build.gradle.kts
plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")

    // 🔑 Para gumana ang Firebase (google-services.json)
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.powerstep_app"

    compileSdk = 36  // ✅ gumamit ng fixed value (safe for Play Store)
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

defaultConfig {
    applicationId = "com.example.powerstep_app"
    minSdk = flutter.minSdkVersion.toInt()
    targetSdk = flutter.targetSdkVersion.toInt()
    versionCode = flutter.versionCode
    versionName = flutter.versionName
}



    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
