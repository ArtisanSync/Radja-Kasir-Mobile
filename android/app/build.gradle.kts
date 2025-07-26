    plugins {
        id("com.android.application")
        id("kotlin-android")
        id("dev.flutter.flutter-gradle-plugin")
    }

    android {
        namespace = "com.example.kasir_baru"
        compileSdk = 35
        ndkVersion = "27.0.12077973"

        compileOptions {
            sourceCompatibility = JavaVersion.VERSION_11
            targetCompatibility = JavaVersion.VERSION_11
        }

        kotlinOptions {
            jvmTarget = JavaVersion.VERSION_11.toString()
        }

        defaultConfig {
            applicationId = "com.example.kasir_baru"
            minSdk = 21  // Pastikan minSdk minimal 21 atau sesuai kebutuhan
            targetSdk = 34  // Pastikan targetSdk versi terbaru (minimal 31, disarankan 34)
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
