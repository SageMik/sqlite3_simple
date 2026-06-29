package io.github.sagemik.simplenative

expect object LibSimple {
    val name: String
    val entrypoint: String
}

internal const val LIB_SIMPLE_ENTRYPOINT = "sqlite3_simple_init"
