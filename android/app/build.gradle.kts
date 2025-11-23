import java.util.Base64
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// ---------- local.properties (for MAPS_API_KEY, etc.) ----------
val localProps = Properties().apply {
    val f = rootProject.file("local.properties")
    if (f.exists()) f.inputStream().use { load(it) }
}

val mapsApiKey: String = localProps.getProperty("MAPS_API_KEY")
    ?: System.getenv("MAPS_API_KEY")
    ?: ""

// ---------- dart-define helpers (for APPLICATION_ID, APP_NAME, etc.) ----------
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

// APPLICATION_ID direct from env (e.g. com.build4all.myhobbysphereapp)
val appIdFromEnv: String? = System.getenv("APPLICATION_ID")

// slug from env (e.g. "my-hobbysphere-app-2")
val slugFromEnv: String? = System.getenv("APP_SLUG")

// sanitize slug → lower + [a–z0–9_]
fun safeFromSlug(raw: String?): String {
    if (raw.isNullOrBlank()) return "hobbysphere"
    return raw
        .lowercase()
        .replace(Regex("[^a-z0-9_]"), "_")
}

// ---------- keystore / signing setup (for Play Store / CI) ----------
val keystoreProps = Properties()
val keystoreFile = rootProject.file("key.properties")
val hasKeystore = keystoreFile.exists()

if (hasKeystore) {
    keystoreFile.inputStream().use { keystoreProps.load(it) }
    println("Using release keystore from key.properties")
} else {
    println("WARNING: key.properties not found; release builds will use DEBUG signing (not Play Store ready).")
}

android {
    namespace = "com.example.hobby_sphere"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    // --- signing configs for release/debug ---
    signingConfigs {
        // default debug config
        getByName("debug") {
            // nothing special needed; standard debug keystore
        }

        // release config: only valid if key.properties exists
        create("release") {
            if (hasKeystore) {
                val storeFileProp = keystoreProps["storeFile"] as String?
                if (!storeFileProp.isNullOrBlank()) {
                    storeFile = file(storeFileProp)
                }

                storePassword = keystoreProps["storePassword"] as String?
                keyAlias = keystoreProps["keyAlias"] as String?
                keyPassword = keystoreProps["keyPassword"] as String?
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

    // turn off lint fatal for release to avoid file-lock issues on CI
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

            // 🔥 IMPORTANT:
            // - If keystore exists -> use REAL release signing (Play Store ready)
            // - If not (like on GitHub Actions) -> fallback to debug signing so build doesn’t crash
            signingConfig = if (hasKeystore) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
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
