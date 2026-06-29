import com.vanniktech.maven.publish.JavadocJar
import com.vanniktech.maven.publish.KotlinJvm

plugins {
    id("publish")
    kotlin("jvm")
}

kotlin {
    jvmToolchain(21)
}

mavenPublishing {
    configure(
        KotlinJvm(
            javadocJar = JavadocJar.Empty(),
            sourcesJar = false,
        )
    )
}