@file:Suppress("ConstPropertyName")

package io.github.sagemik.simplenative

actual object LibSimple {
    actual const val name: String = "libsimple.so"
    actual const val entrypoint: String = LIB_SIMPLE_ENTRYPOINT
}