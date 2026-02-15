import com.vanniktech.maven.publish.AndroidSingleVariantLibrary

plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.maven.publish)

    alias(libsTest.plugins.kotlinAndroid)
}
val isSnapshot = System.getenv("SNAPSHOT")?.toBooleanStrictOrNull() ?: true

group = "io.github.sagemik"
version = "2.0.0" + if(isSnapshot) "-SNAPSHOT" else ""
description = "Simple (支持中文和拼音的 SQLite fts5 全文搜索扩展) 的 Android 原生库，用于 sqlite3_simple Flutter 插件。"

android {
    namespace = "io.github.sagemik.simple_native_android"

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

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
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

    kotlin {
        jvmToolchain(21)
    }
}

/** https://vanniktech.github.io/gradle-maven-publish-plugin/central **/
mavenPublishing {
    publishToMavenCentral(automaticRelease = false)

    signAllPublications()

    configure(
        AndroidSingleVariantLibrary(
            variant = "release",
            sourcesJar = false,
            publishJavadocJar = false
        )
    )

    coordinates(
        groupId = project.group.toString(),
        artifactId = project.name,
        version = project.version.toString()
    )

    pom {

        name = project.name
        description = project.description
        url = "https://github.com/SageMik/sqlite3_simple/tree/simple-native/src/android"

        developers {
            developer {
                id = "sagemik"
                name = "SageMik"
                email = "sagemik@163.com"
                url = "https://github.com/SageMik"
            }
        }

        licenses {
            license {
                name = "MIT license"
                url = "https://mit-license.org"
            }
        }

    }
}

dependencies {
    androidTestImplementation(libsTest.androidx.test.ext.junit)
    androidTestImplementation(libsTest.androidx.test.ext.truth)
    androidTestImplementation(libsTest.androidx.test.core.ktx)
    androidTestImplementation(libsTest.androidx.test.runner)
    androidTestImplementation(libsTest.androidx.test.rules)
    androidTestImplementation(libsTest.sqlite.android)
}