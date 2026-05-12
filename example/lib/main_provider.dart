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

/// 是否展开更多搜索选项
final searchOptionsMoreOpenProvider = mutable(true);

/// 分词器
final tokenizerProvider = mutable<Tokenizer>(Tokenizer.jieba);
const tokenizer2uiString = {Tokenizer.jieba: "结巴", Tokenizer.simple: "Simple"};

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

class _DbBootstrapResult {
  final DbManager dbManager;
  final Map<PinyinDictKind, String> pinyinDictKind2path;
  _DbBootstrapResult(this.dbManager, this.pinyinDictKind2path);
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
    await dbManager.dao.updatePinyinDict(pinyinDictKind2path[ref.read(pinyinDictKindProvider)]!);

    await dbManager.dao.insertRandomData(30);

    return _DbBootstrapResult(dbManager, pinyinDictKind2path);
  }
}

/// [DbManager] 数据库管理类
final dbManagerProvider = AsyncNotifierProvider(DbManagerNotifier.new);
class DbManagerNotifier extends AsyncNotifier<DbManager> {
  @override
  Future<DbManager> build() async {
    final _DbBootstrapResult(:dbManager, :pinyinDictKind2path,) = await ref.watch(_dbBootstrapProvider.future);
    final dao = dbManager.dao;

    /// 切换拼音文件
    final pinyinDictKind = ref.watch(pinyinDictKindProvider);
    await dao.updatePinyinDict(pinyinDictKind2path[pinyinDictKind]!);

    return dbManager;
  }
}

/// 搜索结果
final searchResultProvider = FutureProvider<List<MainTableRowUiModel>?>((
  ref,
) async {
  if (ref.watch(_dbBootstrapProvider).isLoading) {
    return null;
  }
  final dbManager = await ref.watch(dbManagerProvider.future); // 数据库就绪
  final query = ref.watch(searchQueryProvider); // 搜索文本
  final tokenizer = ref.watch(tokenizerProvider); // 分词器

  final dao = dbManager.dao;
  final actualQuery = query.trim();
  final rows = actualQuery.isEmpty
      ? await dao.selectAll()
      : await dao.search(actualQuery, tokenizer);
  final idDigitLength = "${await dao.selectCount()}".length;
  return rows
      .map(
        (r) => MainTableRowUiModel(
          id: r.id,
          idFormatted: "${r.id}".padLeft(idDigitLength, "0"),
          title: r.title,
          content: r.content,
          insertDate: r.insertDate,
        ),
      )
      .toList();
});
