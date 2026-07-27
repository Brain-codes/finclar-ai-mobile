import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}

// Release signing is read from android/key.properties (gitignored). When that file
// is absent (e.g. a fresh clone or CI without secrets) the release build falls back
// to debug signing so `flutter run --release` still works.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.finclar.finclar_ai"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.finclar.finclarAi"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = (keystoreProperties["storeFile"] as String?)?.let { file(it) }
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (keystorePropertiesFile.exists())
                signingConfigs.getByName("release")
            else
                signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Firebase App Distribution in-app tester feedback (screenshot + notes).
    // The API-only library is safe in every variant and makes the calls compile;
    // they no-op unless the full SDK is present. The full SDK contains self-update
    // functionality that violates Google Play policy, so it is kept out of debug
    // builds here and, crucially, MUST be excluded from any Google Play build.
    //
    // ⚠️ BEFORE SHIPPING TO GOOGLE PLAY: move the full SDK to a testing-only
    // product flavor so the Play artifact ships api-only. See docs/RELEASE_PIPELINE.md.
    implementation("com.google.firebase:firebase-appdistribution-api:16.0.0-beta20")
    "releaseImplementation"("com.google.firebase:firebase-appdistribution:16.0.0-beta20")
}
