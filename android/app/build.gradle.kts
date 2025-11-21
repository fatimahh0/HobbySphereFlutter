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

// ===== dynamic applicationId support (from dart-define or env) =====

// APPLICATION_ID from dart-define (preferred if present)
fun dartDefine(name: String): String? {
    val raw = project.findProperty("dart-defines") as String? ?: return null
    return raw.split(",")
        .mapNotNull { encoded ->
            try {
                String(Base64.getDecoder().decode(encoded))
            } catch (_: Exception) {
                null
            }
        }
        .mapNotNull { kv ->
            val idx = kv.indexOf("=")
            if (idx > 0) kv.substring(0, idx) to kv.substring(idx + 1) else null
        }
        .toMap()[name]
}

// APPLICATION_ID direct from env (e.g. com.build4all.my_owner_1)
val appIdFromEnv: String? = System.getenv("APPLICATION_ID")

// slug from env (e.g. "my-owner-1")
val slugFromEnv: String? = System.getenv("APP_SLUG")

// sanitize slug → lower + [a–z0–9_]
fun safeFromSlug(raw: String?): String {
    if (raw.isNullOrBlank()) return "hobbysphere"
    return raw
        .lowercase()
        .replace(Regex("[^a-z0-9_]"), "_")
}

android {
    namespace = "com.example.hobby_sphere"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    // --- signing configs for release build (Play Store) ---
    signingConfigs {
        create("release") {
            val keystoreProps = Properties()
            val keystoreFile = rootProject.file("key.properties")
            if (keystoreFile.exists()) {
                keystoreFile.inputStream().use { keystoreProps.load(it) }

                val storeFileProp = keystoreProps["storeFile"] as String?
                if (!storeFileProp.isNullOrBlank()) {
                    storeFile = file(storeFileProp)
                }

                storePassword = keystoreProps["storePassword"] as String?
                keyAlias = keystoreProps["keyAlias"] as String?
                keyPassword = keystoreProps["keyPassword"] as String?
            } else {
                println("WARNING: key.properties not found; release build will fail for Play Store.")
            }
        }
    }

    defaultConfig {
        // ===== resolve applicationId dynamically =====
        val appIdFromDart = dartDefine("APPLICATION_ID")

        val baseId = when {
            !appIdFromDart.isNullOrBlank() -> appIdFromDart
            !appIdFromEnv.isNullOrBlank() -> appIdFromEnv
            !slugFromEnv.isNullOrBlank()   -> "com.build4all." + safeFromSlug(slugFromEnv)
            else                           -> "com.example.hobby_sphere"
        }

        applicationId = baseId
        println("Using APPLICATION_ID = $baseId")

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
            resValue("string", "app_name", appNameFromDart)
            println("Using APP_NAME from dart-define: $appNameFromDart")
        } else {
            println("APP_NAME dart-define not provided; using default res/values/strings.xml")
        }
    }

    // turn off lint fatal for release to avoid file-lock issues
    lint {
        abortOnError = false
        checkReleaseBuilds = false
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
            isShrinkResources = false
            signingConfig = signingConfigs.getByName("release")
        }
        getByName("debug") {
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

// extra safety: disable this specific lint task if Gradle still insists on running it
tasks.matching { it.name == "lintVitalAnalyzeRelease" }.configureEach {
    enabled = false
}
