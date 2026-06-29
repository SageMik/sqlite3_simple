@file:Suppress("NewApi")

package io.github.sagemik.buildconfig

import org.gradle.api.Project
import java.util.Properties

fun Project.resolveArtifactId(): String {
    if (!path.startsWith(":platforms:")) {
        return name
    }
    val suffix = path
        .removePrefix(":platforms:")
        .replace(':', '-')
    return "simple-native-$suffix"
}