import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

android {
    namespace = "org.gulfcoastmesh"
    compileSdk = flutter.compileSdkVersion
    // Pinned explicitly (rather than flutter.ndkVersion) so 16 KB page-size
    // support doesn't silently regress if a future Flutter SDK bundles an
    // older NDK default. r28+ is required to avoid prebuilt native libs
    // (e.g. androidx datastore's libdatastore_shared_counter.so) crashing on
    // 16 KB page-size devices.
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "org.gulfcoastmesh"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val storeFilePath = keystoreProperties["storeFile"] as String?
            if (storeFilePath != null) {
                storeFile = file(storeFilePath)
                storePassword = keystoreProperties["storePassword"] as String?
                keyAlias = keystoreProperties["keyAlias"] as String?
                keyPassword = keystoreProperties["keyPassword"] as String?
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }

    packaging {
        jniLibs {
            // androidx.datastore ships this prebuilt compiled with NDK r20, which
            // Play flags as a 16 KB page-size crash risk. It cannot be rebuilt from
            // here and 1.2.0 is already the current release, so a version bump does
            // not help. It is only ever dlopen'd by MultiProcessDataStore
            // (androidx.datastore.core.SharedCounter), and shared_preferences_android
            // uses the single-process `preferencesDataStore` delegate — so nothing in
            // this app can reach it. Drop it from the bundle.
            excludes += "**/libdatastore_shared_counter.so"
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    // NotificationCompat.MessagingStyle / Person / RemoteInput and the
    // SEMANTIC_ACTION_* constants Android Auto requires. Declared explicitly
    // rather than relied on transitively, since the car integration breaks
    // silently without it.
    implementation("androidx.core:core-ktx:1.15.0")
}
