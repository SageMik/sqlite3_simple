enum PinyinDictKind {
  /// `sqlite3_simple` 自行维护的内置拼音文件
  bundled(null),

  /// 原 Simple 扩展内置的拼音文件
  simpleDefault("simple_default.txt");

  static const String _dir = "assets/pinyin_dict";

  final String? assetName;
  final String? assetPath;

  const PinyinDictKind(this.assetName)
    : assetPath = assetName == null ? null : "$_dir/$assetName";

  bool get isBundled => this == bundled;
 }
