plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.financial_planner_app"
    // DIUBAH: Naikkan ke versi 36 sesuai permintaan plugin
    compileSdk = 36

    compileOptions {
        // Tetapkan versi Java ke 1.8 yang stabil
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        // DIUBAH: Samakan versi target Kotlin dengan Java untuk konsistensi
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.financial_planner_app"
        // DIUBAH: Naikkan ke versi 24 sesuai warning Flutter
        minSdkVersion(24)
        // DIUBAH: Sesuaikan dengan compileSdk
        targetSdkVersion(36)
        versionCode = 1
        versionName = "1.0"
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

dependencies {
    // Dependensi standar kotlin, tidak perlu desugaring jika tidak ada notifikasi
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.9.23")
}