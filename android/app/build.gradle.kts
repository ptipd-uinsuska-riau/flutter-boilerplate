import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "id.ac.uinsuska.starter"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // GANTI lewat `dart run tool/rename.dart --app-id ...` (jangan
        // disunting tangan: namespace, folder Kotlin, dan iOS ikut berubah).
        applicationId = "id.ac.uinsuska.starter"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        // Keystore debug BERSAMA (opsional): taruh `android/app/debug.keystore`
        // (git-ignored, password bawaan Android) supaya seluruh tim punya
        // SATU SHA-1 debug yang didaftarkan sebagai OAuth Android client.
        // Tanpa berkas itu, build debug memakai keystore debug bawaan
        // tiap komputer (SHA-1 berbeda-beda → Google Sign-In ditolak di
        // komputer yang SHA-1-nya belum didaftarkan).
        getByName("debug") {
            val shared = file("debug.keystore")
            if (shared.exists()) {
                storeFile = shared
                storePassword = "android"
                keyAlias = "androiddebugkey"
                keyPassword = "android"
            }
        }
        create("release") {
            if (System.getenv("ANDROID_KEYSTORE_PATH") != null) {
                storeFile = file(System.getenv("ANDROID_KEYSTORE_PATH"))
                keyAlias = System.getenv("ANDROID_KEYSTORE_ALIAS")
                keyPassword = System.getenv("ANDROID_KEYSTORE_PRIVATE_KEY_PASSWORD")
                storePassword = System.getenv("ANDROID_KEYSTORE_PASSWORD")
                
            } else {
                keyAlias = keystoreProperties["keyAlias"] as String?
                keyPassword = keystoreProperties["keyPassword"] as String?
                storeFile = keystoreProperties["storeFile"]?.let { file(it) }
                storePassword = keystoreProperties["storePassword"] as String?
            }
        }
    }

    // Semua flavor memakai applicationId yang SAMA: OAuth Android client
    // terikat ke package + SHA-1, jadi suffix .dev/.stg berarti mendaftarkan
    // client baru per flavor. Konsekuensi: dev/stg/prod tidak bisa terpasang
    // berdampingan di satu perangkat.
    flavorDimensions += "default"
    productFlavors {
        create("production") {
            dimension = "default"
            applicationIdSuffix = ""
            manifestPlaceholders["appName"] = "Suska Starter"
        }
        create("staging") {
            dimension = "default"
            applicationIdSuffix = ""
            manifestPlaceholders["appName"] = "[STG] Suska Starter"
        }
        create("development") {
            dimension = "default"
            applicationIdSuffix = ""
            manifestPlaceholders["appName"] = "[DEV] Suska Starter"
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android.txt"),
                "proguard-rules.pro"
            )
        }
        getByName("debug") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib:2.2.20")
}
