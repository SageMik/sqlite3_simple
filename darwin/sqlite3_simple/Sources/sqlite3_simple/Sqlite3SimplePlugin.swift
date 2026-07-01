import Foundation
import CSimple

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#endif

public class Sqlite3SimplePlugin: NSObject, FlutterPlugin {
  private static var symbolAnchor: UnsafeRawPointer?

  public static func register(with registrar: FlutterPluginRegistrar) {
    symbolAnchor = keepSimpleSymbol()
  }

  // 由于编译期没有 Swift/ObjC 代码调用 Simple 原生库，
  // 链接器会将 `sqlite3_simple_init` 视为未使用而进行 dead-strip，导致 Flutter 层 SQLite 无法加载 Simple 扩展。
  // 为此，通过提供 CSimple.xcframwork 和 `keepSimpleSymbol` 兼容 Swift Package Manager 和 CocoaPods，解决此问题。
  @inline(never)
  private static func keepSimpleSymbol() -> UnsafeRawPointer {
    let entry: @convention(c) (
      UnsafeMutableRawPointer?,
      UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?,
      UnsafeRawPointer?
    ) -> Int32 = sqlite3_simple_init
    return unsafeBitCast(entry, to: UnsafeRawPointer.self)
  }
}
