plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.rubiapp2"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.rubiapp2"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Añadir soporte para múltiples arquitecturas
        ndk {
            abiFilters.add("armeabi-v7a")  // Para dispositivos Cortex-A53 (32-bit)
            abiFilters.add("arm64-v8a")    // Para dispositivos Cortex-A76 (64-bit)
            abiFilters.add("x86")          // Para emuladores x86
            abiFilters.add("x86_64")       // Para emuladores x86_64
        }
    }

    // Leer propiedades del keystore
    val keystorePropertiesFile = rootProject.file("key.properties")
    val keystoreProperties = mutableMapOf<String, String>()
    
    if (keystorePropertiesFile.exists()) {
        keystorePropertiesFile.forEachLine { line ->
            if (line.isNotEmpty() && !line.startsWith("#")) {
                val parts = line.split("=", limit = 2)
                if (parts.size == 2) {
                    keystoreProperties[parts[0].trim()] = parts[1].trim()
                }
            }
        }
    }

    // Configurar firma de APK
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"]
            keyPassword = keystoreProperties["keyPassword"]
            storeFile = file(keystoreProperties["storeFile"] ?: "key.jks")
            storePassword = keystoreProperties["storePassword"]
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}
