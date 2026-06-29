package io.github.sagemik.test

import io.github.sagemik.simplenative.LibSimple
import okio.FileSystem

/** JVM 平台要额外将 Simple 原生库写到本地使用 */
actual fun FileSystem.initLibSimple(): String {
    val libSimplePath = resourcesDir / LibSimple.name
    write(libSimplePath) {
        write(LibSimple.readBytes())
    }
    return libSimplePath.toString()
}