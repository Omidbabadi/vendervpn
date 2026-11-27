import java.util.Properties

plugins {
    id("com.android.application")
    //id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Google's sample AdMob app ID: test ads only. Debug always uses it; release
// uses ADMOB_ANDROID_APP_ID from a Gradle property, an environment variable or
// android/secrets.properties (git-ignored, see secrets.example.properties).
val admobSampleAppId = "ca-app-pub-3940256099942544~3347511713"
val secretProps = Properties().apply {
    val file = rootProject.file("secrets.properties")
    if (file.exists()) file.inputStream().use { load(it) }
}
fun secret(key: String): String? =
    (findProperty(key) as String?)?.takeIf { it.isNotBlank() }
        ?: System.getenv(key)?.takeIf { it.isNotBlank() }
        ?: secretProps.getProperty(key)?.takeIf { it.isNotBlank() }

android {
    namespace = "com.vender.vendervpn"
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    defaultConfig {
        applicationId = "com.vender.vendervpn"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
        manifestPlaceholders["admobAppId"] = admobSampleAppId
    }

    buildTypes {
        release {
            manifestPlaceholders["admobAppId"] =
                secret("ADMOB_ANDROID_APP_ID") ?: admobSampleAppId.also {
                    logger.warn("ADMOB_ANDROID_APP_ID not set: release build uses the AdMob sample app ID")
                }
            signingConfig = signingConfigs.getByName("debug")
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

// Modern Kotlin compiler options configured via Kotlin extension
kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11)
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
}