#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint sqlite3_simple.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'sqlite3_simple'
  s.version          = '0.0.1'
  s.summary          = '基于 Simple (支持中文和拼音的 sqlite3 fts5 拓展) 的 Flutter 库。'
  s.description      = <<-DESC
基于 Simple (支持中文和拼音的 sqlite3 fts5 拓展) 的 Flutter 库。
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
