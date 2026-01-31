import com.vanniktech.maven.publish.AndroidSingleVariantLibrary

plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.maven.publish)
}
val isSnapshot = System.getenv("SNAPSHOT")?.toBooleanStrictOrNull() ?: true

group = "io.github.sagemik"
version = "2.0.0" + if(isSnapshot) "-SNAPSHOT" else ""
description = "Simple 的 Android 原生库，用于 sqlite3_simple Flutter 插件。"

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

        scm {
            url = "https://github.com/SageMik/sqlite3_simple"
            connection = "scm:git:https://github.com/SageMik/sqlite3_simple.git"
            developerConnection = "scm:git:ssh://git@github.com/SageMik/sqlite3_simple.git"
        }
    }
}
