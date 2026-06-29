pluginManagement {
    repositories {
        maven("https://mirrors.cloud.tencent.com/nexus/repository/maven-public")
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

@Suppress("UnstableApiUsage")
dependencyResolutionManagement {
    repositories {
        maven("https://mirrors.cloud.tencent.com/nexus/repository/maven-public")
        google()
        mavenCentral()
    }

    versionCatalogs {
        create("libsExample") {
            from(files("gradle/libsExample.versions.toml"))
        }
    }
}

includeBuild("build-logic")

include(":example")
include(":script")

include(":platforms:jvm-windows")
include(":platforms:jvm-macos")
include(":platforms:jvm-linux")

include(":simple-native-kmp")
