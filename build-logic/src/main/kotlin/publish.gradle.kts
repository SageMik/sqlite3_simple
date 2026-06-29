import io.github.sagemik.buildconfig.resolveArtifactId

plugins {
    alias(libs.plugins.maven.publish)
}

group = "io.github.sagemik"
version = "2.2.0"

mavenPublishing {
    publishToMavenCentral(automaticRelease = false)

    signAllPublications()

    val artifactId = resolveArtifactId()
    coordinates(
        groupId = group.toString(),
        artifactId = artifactId,
        version = version.toString()
    )

    pom {
        name = artifactId
        description = project.description
        inceptionYear = "2026"
        url = "https://github.com/SageMik/sqlite3_simple/tree/simple-native-kmp"

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
            url = "https://github.com/SageMik/sqlite3_simple.git"
            connection = "scm:git:https://github.com/SageMik/sqlite3_simple.git"
            developerConnection = "scm:git:ssh://git@github.com/SageMik/sqlite3_simple.git"
        }
    }
}