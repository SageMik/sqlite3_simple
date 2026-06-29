package io.github.sagemik.test

import io.github.sagemik.simplenative.LibSimple
import okio.FileSystem

/** 安卓自动将 Simple 原生库复制到应用数据目录下，可以直接使用，不需要手动复制 */
actual fun FileSystem.initLibSimple(): String = LibSimple.name