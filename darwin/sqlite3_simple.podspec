Pod::Spec.new do |s|
  s.name             = 'sqlite3_simple'
  s.version          = '2.2.0'
  s.summary          = '基于 Simple (支持中文和拼音的 SQLite fts5 全文搜索扩展) 和 sqlite3.dart 的 Flutter 库，用于 SQLite 中文和拼音全文搜索。'
  s.description      = <<-DESC
基于 Simple (支持中文和拼音的 SQLite fts5 全文搜索扩展) 和 sqlite3.dart 的 Flutter 库，用于 SQLite 中文和拼音全文搜索。
                       DESC
  s.homepage         = 'https://github.com/SageMik/sqlite3_simple'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'SageMik' => 'sagemik@163.com' }
  s.source           = { :path => '.' }
  s.source_files = 'sqlite3_simple/Sources/sqlite3_simple/**/*.swift', 'sqlite3_simple/Sources/sqlite3_simple_anchor/**/*.c'
  s.swift_version = '5.0'

  s.ios.dependency 'Flutter'
  s.osx.dependency 'FlutterMacOS'
  s.ios.deployment_target = '12.0'
  s.osx.deployment_target = '10.14'

  s.vendored_frameworks = 'sqlite3_simple/CSimple.xcframework'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
  }
end
