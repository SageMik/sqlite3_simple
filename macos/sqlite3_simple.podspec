Pod::Spec.new do |s|
  s.name             = 'sqlite3_simple'
  s.version          = '1.0.4'
  s.summary          = '基于 Simple (支持中文和拼音的 SQLite fts5 全文搜索扩展) 和 sqlite3.dart 的 Flutter 库，用于 SQLite 中文和拼音全文搜索。'
  s.description      = <<-DESC
基于 Simple (支持中文和拼音的 SQLite fts5 全文搜索扩展) 和 sqlite3.dart 的 Flutter 库，用于 SQLite 中文和拼音全文搜索。
                       DESC
  s.homepage         = 'https://github.com/SageMik/sqlite3_simple'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'SageMik' => 'sagemik@163.com' }

  s.source           = { :path => '.' }
  s.dependency 'FlutterMacOS'
  s.vendored_libraries = 'libsimple.dylib'
  s.static_framework = true
  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
