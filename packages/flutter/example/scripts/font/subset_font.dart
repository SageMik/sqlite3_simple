// ignore_for_file: avoid_print

import 'dart:io';

final scriptDir = File(Platform.script.toFilePath()).parent;
final exampleDir = scriptDir.parent.parent;
final projectRoot = exampleDir.parent;
final srcFont = File('${scriptDir.path}/HarmonyOS_Sans_SC_Regular.ttf');

/// 完整子集的 Unicode 范围：ASCII + 拉丁补充 + 通用标点 + CJK 标点 + CJK 统一汉字 + 全角
const fullUnicodeRange =
    'U+0020-007F,U+00A0-00FF,U+2000-206F,U+3000-303F,U+4E00-9FFF,U+FF00-FFEF';

/// 首屏字符正则：汉字 + CJK 标点 + 全角符号 + ASCII
final firstScreenRe = RegExp(
  r'[\u4e00-\u9fff\u3000-\u303f\uff00-\uffef\u0020-\u007e]',
);

/// 字节数转 MB 字符串（保留 2 位小数）
String mb(int bytes) => (bytes / 1024 / 1024).toStringAsFixed(2);

Future<void> main() async {
  print('[i] 原字体大小：${mb(srcFont.lengthSync())} MB\n');

  /// 非 Web: subset.ttf（GB2312 常用字 + ASCII）
  await runSubset(
    '${exampleDir.path}/assets/font/HarmonyOS_Sans_SC_Regular.subset.ttf',
    unicodeRange: fullUnicodeRange,
    hinting: false,
  );

  /// Web: subset.woff2（GB2312 常用字 + ASCII）
  await runSubset(
    '${exampleDir.path}/web/fonts/HarmonyOS_Sans_SC_Regular.subset.woff2',
    flavor: 'woff2',
    unicodeRange: fullUnicodeRange,
  );

  /// Web 首屏: first_screen.woff2 (lib 目录下所有 *.dart 的实际用字)
  final chars = Directory('${exampleDir.path}/lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .expand((f) => firstScreenRe.allMatches(f.readAsStringSync()))
      .map((m) => m.group(0)!)
      .toSet()
      .join();
  print('[*] 首屏字符集：${chars.length} 个字符');
  await runSubset(
    '${exampleDir.path}/web/fonts/HarmonyOS_Sans_SC_Regular.first_screen.woff2',
    flavor: 'woff2',
    text: chars,
  );
}

/// 调用 `python -m fontTools.subset` 生成子集字体到指定位置。
Future<void> runSubset(
  /// 输出文件路径
  String outPath, {

  /// 输出格式（'woff2' / 'woff'）；null 表示保持源格式
  String? flavor,

  /// Unicode 范围，对应 pyftsubset `--unicodes`（如 'U+4E00-9FFF'）
  String? unicodeRange,

  /// 精确字符集，对应 pyftsubset `--text`；与 [unicode Range] 互斥，同时传时以本参数为准
  String? text,

  /// 是否保留 hinting；关闭可进一步缩小体积（web woff2 通常关闭）
  bool hinting = true,
}) async {
  final out = File(outPath);
  await out.parent.create(recursive: true);
  final args = <String>[
    '-m',
    'fontTools.subset',
    srcFont.path,
    '--output-file=${out.path}',
    '--layout-features=*',
    if (!hinting) '--no-hinting' else '--hinting',
    '--desubroutinize',
    if (flavor != null) '--flavor=$flavor',
    if (unicodeRange != null) '--unicodes=$unicodeRange',
    if (text != null) '--text=$text',
  ];
  print('[*] 生成 ${Uri.file(out.absolute.path).toFilePath()}');
  final result = await Process.run('python', args);
  if (result.exitCode != 0) {
    stderr.writeln(result.stderr);
    exit(result.exitCode);
  }
  final srcBytes = srcFont.lengthSync();
  final outBytes = out.lengthSync();
  final pct = (outBytes / srcBytes * 100).toStringAsFixed(1);
  print('    → ${mb(outBytes)} MB ($pct%)');
}
