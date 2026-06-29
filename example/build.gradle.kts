plugins {
    alias(libs.plugins.kotlin.multiplatform)
    alias(libs.plugins.android.kotlin.multiplatform.library)
    alias(libsExample.plugins.kotlinx.resources)
}

group = "io.github.sagemik"
version = "1.0.0"

kotlin {
    jvmToolchain(21)
    androidLibrary {
        namespace = "$group.test"
        //noinspection GradleDependency
        compileSdk = 36
        withDeviceTestBuilder {
            sourceSetTreeName = "test"
        }
        minSdk = 24
    }
//    iosArm64()
//    iosSimulatorArm64()
    jvm()

    sourceSets {
        commonMain.dependencies {
            implementation(project(":simple-native-kmp"))
        }
        commonTest.dependencies {
            implementation(libsExample.kotlin.test)
            implementation(libsExample.androidx.sqlite)
            implementation(libsExample.androidx.sqlite.bundled)
            implementation(libsExample.okio)
            implementation(libsExample.kotlinx.resources)
            implementation(libsExample.multiplatform.path.provider)
        }
        getByName("androidDeviceTest").dependencies {
            implementation(libsExample.androidx.test.runner)
        }
    }
}
