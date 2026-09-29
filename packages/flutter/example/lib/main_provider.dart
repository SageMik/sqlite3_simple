import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/db_manager.dart';
import 'data/db_manager_kind.dart';
import 'data/main_table_dao.dart';
import 'data/main_table_row.dart';
import 'data/modifiable_notifier.dart';
import 'data/pinyin_dict_kind.dart';

/// 搜索文本
final searchQueryProvider = mutable<String>("");

/// 当前选中用于检视的结果行
final selectedRowProvider = mutable<MainTableRowUiModel?>(null);

/// 上次重建 FTS5 索引耗时（切换拼音字典 / 数据库实现时记录）
final indexRebuildDurationProvider = mutable<Duration?>(null);

/// 分词器
final tokenizerProvider = mutable<Tokenizer>(Tokenizer.jieba);
const tokenizer2uiString = {Tokenizer.jieba: "结巴", Tokenizer.simple: "Simple"};
const tokenizer2tooltip = {
  Tokenizer.jieba: "jieba_query：结巴分词",
  Tokenizer.simple: "simple_query：Simple 分词",
};

/// [DbManager] 具体实现。
///  - 非 Web 平台： `data\impl\kind.dart`；
///  - Web 平台：`data\impl_web\kind.dart`。
final dbManagerKindProvider = mutable(dbManagerKind2uiString.keys.first);
final dbManagerKind2uiString = {
  for (final t in DbManagerKind.values) t: t.name,
};

/// 拼音文件
final pinyinDictKindProvider = mutable(PinyinDictKind.bundled);
const pinyinDictKind2uiString = {
  PinyinDictKind.bundled: "内置 (zdic.txt)",
  PinyinDictKind.simpleDefault: "原 Simple 扩展内置",
};
const pinyinDictKind2tooltip = {
  PinyinDictKind.bundled: "sqlite3_simple 自行维护的内置拼音文件",
  PinyinDictKind.simpleDefault: "原 Simple 扩展内置的拼音文件，包含较多不常见古音",
};

class _DbBootstrapResult {
  final DbManager dbManager;
  final Map<PinyinDictKind, String> pinyinDictKind2path;
  const _DbBootstrapResult(this.dbManager, this.pinyinDictKind2path);
}
final _dbBootstrapProvider = AsyncNotifierProvider(_DbBootstrapNotifier.new);
class _DbBootstrapNotifier extends AsyncNotifier<_DbBootstrapResult> {
  @override
  Future<_DbBootstrapResult> build() async {
    final kind = ref.watch(dbManagerKindProvider);
    final dbManager = kind.create();
    ref.onDispose(dbManager.close); // 如果初始化抛出异常，调用 `close` 可能触发 `dao` 未初始化报错
    await dbManager.init();

    final pinyinDictKind2path = await dbManager.savePinyinDict();

    await dbManager.dao.insertRandomData(30);

    return _DbBootstrapResult(dbManager, pinyinDictKind2path);
  }
}

/// [DbManager] 数据库管理类
final dbManagerProvider = AsyncNotifierProvider(DbManagerNotifier.new);
class DbManagerNotifier extends AsyncNotifier<DbManager> {
  @override
  Future<DbManager> build() async {
    final _DbBootstrapResult(:dbManager, :pinyinDictKind2path) = await ref.watch(_dbBootstrapProvider.future);
    final dao = dbManager.dao;

    /// 切换拼音文件
    final pinyinDictKind = ref.watch(pinyinDictKindProvider);
    await dao.updatePinyinDict(pinyinDictKind2path[pinyinDictKind]!);

    return dbManager;
  }
}

/// 主表当前行数
final mainTableCountProvider = FutureProvider<int>((ref) async {
  final dbManager = await ref.watch(dbManagerProvider.future);
  return dbManager.dao.selectCount();
});

/// 一次查询的结果与统计信息
class SearchResult {
  /// 结果行
  final List<MainTableRowUiModel> rows;

  /// 实际执行的查询词，空串表示列出全部
  final String query;

  /// 走 FTS5 `MATCH` 时使用的分词器；列出全部时为 `null`
  final Tokenizer? tokenizer;

  /// 查询耗时
  final Duration elapsed;

  const SearchResult({
    required this.rows,
    required this.query,
    required this.tokenizer,
    required this.elapsed,
  });
}

/// 搜索结果
final searchResultProvider = FutureProvider<SearchResult?>((ref) async {
  if (ref.watch(_dbBootstrapProvider).isLoading) {
    return null;
  }
  final dbManager = await ref.watch(dbManagerProvider.future); // 数据库就绪
  final query = ref.watch(searchQueryProvider); // 搜索文本
  final tokenizer = ref.watch(tokenizerProvider); // 分词器

  final dao = dbManager.dao;
  final actualQuery = query.trim();
  final stopwatch = Stopwatch()..start();
  final rows = actualQuery.isEmpty
      ? await dao.selectAll()
      : await dao.search(actualQuery, tokenizer);
  stopwatch.stop();

  final idDigitLength = "${await dao.selectCount()}".length;
  return SearchResult(
    rows: rows
        .map(
          (r) => MainTableRowUiModel(
            id: r.id,
            idFormatted: "${r.id}".padLeft(idDigitLength, "0"),
            title: r.title,
            content: r.content,
            insertDate: r.insertDate,
          ),
        )
        .toList(),
    query: actualQuery,
    tokenizer: actualQuery.isEmpty ? null : tokenizer,
    elapsed: stopwatch.elapsed,
  );
});

/// 重新生成全部随机数据（同时测试触发器）
Future<void> refreshDbData(WidgetRef ref) async {
  final dbManager = await ref.read(dbManagerProvider.future);
  await dbManager.dao.updateAll();
  ref.invalidate(mainTableCountProvider);
  ref.invalidate(searchResultProvider);
  await ref.read(searchResultProvider.future);
}

/// 追加 [length] 行随机数据
Future<void> appendRandomData(WidgetRef ref, int length) async {
  final dbManager = await ref.read(dbManagerProvider.future);
  await dbManager.dao.insertRandomData(length);
  ref.invalidate(mainTableCountProvider);
  ref.invalidate(searchResultProvider);
  await ref.read(searchResultProvider.future);
}