@file:Suppress("ConstPropertyName")

package io.github.sagemik.simplenative

import kotlin.jvm.Throws

private inline fun <T> whenHostOs(
    onWindows: () -> T,
    onMacOs: () -> T,
    onLinux: () -> T,
): T {
    val hostOs = System.getProperty("os.name")
    return when {
        hostOs.startsWith("Windows") -> onWindows()
        hostOs == "Mac OS X" -> onMacOs()
        hostOs == "Linux" -> onLinux()
        else -> throw IllegalStateException("Unsupported host OS: $hostOs")
    }
}

private const val libSimpleWindows = "simple.dll"
private const val libSimpleMacOs = "libsimple.dylib"
private const val libSimpleLinux = "libsimple.so"

actual object LibSimple {

    @get:Throws(IllegalStateException::class)
    actual val name: String
        get() = whenHostOs(
            onWindows = { libSimpleWindows },
            onMacOs = { libSimpleMacOs },
            onLinux = { libSimpleLinux }
        )

    actual const val entrypoint: String = LIB_SIMPLE_ENTRYPOINT

    @Throws(IllegalStateException::class, RuntimeException::class)
    fun readBytes(): ByteArray =
        try {
            object {}.javaClass.classLoader.getResourceAsStream(
                "io/sagemik/simplenative/" + whenHostOs(
                    onWindows = { "windows/$libSimpleWindows" },
                    onMacOs = { "macos/$libSimpleMacOs" },
                    onLinux = { "linux/$libSimpleLinux" }
                )
            )!!.use { it.readBytes() }
        } catch (e: Exception) {
            throw RuntimeException("Failed to read libsimple bytes", e)
        }
}