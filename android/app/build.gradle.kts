// android/app/build.gradle.kts
import java.util.Base64
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val localProps = Properties().apply {
    val f = rootProject.file("local.properties")
    if (f.exists()) f.inputStream().use { load(it) }
}

val mapsApiKey: String = localProps.getProperty("MAPS_API_KEY")
    ?: System.getenv("MAPS_API_KEY")
    ?: ""

// --- Read a single --dart-define by key (Flutter passes them base64 in "dart-defines") ---
fun dartDefine(name: String): String? {
    val raw = project.findProperty("dart-defines") as String? ?: return null
    return raw.split(",")
        .mapNotNull { encoded ->
            try { String(Base64.getDecoder().decode(encoded)) } catch (_: Exception) { null }
        }
        .mapNotNull { kv ->
            val idx = kv.indexOf("=")
            if (idx > 0) kv.substring(0, idx) to kv.substring(idx + 1) else null
        }
        .toMap()[name]
}

android {
    namespace = "com.example.hobby_sphere"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.example.hobby_sphere"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true

        // Google Maps API key for manifest placeholder
        manifestPlaceholders["MAPS_API_KEY"] = mapsApiKey

        // --- Override launcher label from --dart-define=APP_NAME=... ---
        val appNameFromDart = dartDefine("APP_NAME")
        if (!appNameFromDart.isNullOrBlank()) {
            // Replaces @string/app_name at build time
            resValue("string", "app_name", appNameFromDart)
            println("Using APP_NAME from dart-define: $appNameFromDart")
        } else {
            println("APP_NAME dart-define not provided; using default res/values/strings.xml")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            isShrinkResources = false
            signingConfig = signingConfigs.getByName("debug")
        }
        debug {
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.appcompat:appcompat:1.7.0")
    implementation("com.google.android.material:material:1.12.0")
    implementation("androidx.multidex:multidex:2.0.1")

    // Compose (kept from your file – not strictly required for a Flutter app)
    implementation(platform("androidx.compose:compose-bom:2024.06.00"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.foundation:foundation")
    implementation("androidx.compose.runtime:runtime")
}
