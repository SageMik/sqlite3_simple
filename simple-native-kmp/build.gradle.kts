import org.jetbrains.kotlin.konan.target.HostManager.Companion.simpleOsName

plugins {
    id("publish")
    alias(libs.plugins.kotlin.multiplatform)
    alias(libs.plugins.android.kotlin.multiplatform.library)
}

description =
    "Simple (支持中文和拼音的 SQLite fts5 全文搜索扩展) 的 Kotlin Multiplatform 库，包含 Simple 的 Android/iOS/Windows/MacOS/Linux 原生库。"

kotlin {
    jvmToolchain(21)
    compilerOptions {
        freeCompilerArgs.add("-Xexpect-actual-classes")
    }

    android {
        namespace = "$group.simple_native_android"
        //noinspection GradleDependency
        compileSdk = libs.versions.android.compileSdk.get().toInt()
        withDeviceTestBuilder {
            sourceSetTreeName = "test"
        }
        minSdk = libs.versions.android.minSdk.get().toInt()
    }
//    iosArm64()
//    iosSimulatorArm64()
    jvm()

    sourceSets {
        androidMain.dependencies {
            implementation("io.github.sagemik:simple-native-android:$version")
        }
        jvmMain.dependencies {
            implementation(project(":platforms:jvm-${simpleOsName()}"))
        }
    }
}
