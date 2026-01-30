plugins {
    alias(libs.plugins.android.library)
}

android {
    namespace = "io.github.sagemik.library"
    compileSdk = 36
    ndkVersion = "29.0.14206865"

    defaultConfig {
        minSdk = 21

        ndk {
            abiFilters += setOf(
                "arm64-v8a",
                "armeabi-v7a",
                "x86",
                "x86_64"
            )
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = false
        }
    }

    externalNativeBuild {
        cmake {
            version = "3.22.1"
            path = rootDir.resolve("../../CMakeLists.txt").normalize()
        }
    }
}