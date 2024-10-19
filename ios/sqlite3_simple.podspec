Pod::Spec.new do |s|
  s.name             = 'sqlite3_simple'
  s.version          = '1.0.1'
  s.summary          = '基于 Simple (支持中文和拼音的 SQLite fts5 全文搜索扩展) 和 sqlite3.dart 的 Flutter 库，用于 SQLite 中文和拼音全文搜索。'
  s.description      = <<-DESC
基于 Simple (支持中文和拼音的 SQLite fts5 全文搜索扩展) 和 sqlite3.dart 的 Flutter 库，用于 SQLite 中文和拼音全文搜索。
                       DESC
  s.homepage         = 'https://github.com/SageMik/sqlite3_simple'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'SageMik' => 'sagemik@163.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  
  # 通过 s.vendored_libraries 加载 libsimple.a 失败，
  # 推测是因为 Dart FFI 直接调用，iOS 原生没有调用，而被优化，
  # 故通过 force_load 强制加载
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    "OTHER_LDFLAGS[sdk=iphonesimulator*]" => "-force_load $(PODS_TARGET_SRCROOT)/iphone_simulator/libsimple.a",
    "OTHER_LDFLAGS" => "-force_load $(PODS_TARGET_SRCROOT)/iphone_os/libsimple.a" ,
  }
  s.swift_version = '5.0'
end
