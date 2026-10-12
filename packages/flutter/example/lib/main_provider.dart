import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/db_manager.dart';
import 'data/db_manager_kind.dart';
import 'data/main_table_dao.dart';
import 'data/main_table_row.dart';
import 'data/modifiable_notifier.dart';
import 'data/pinyin_dict_kind.dart';
import 'data/search_result.dart';
import 'utils/ui_label.dart';

/// 搜索文本
final searchQueryProvider = mutable<String>("");

/// 分词器
final tokenizerProvider = mutable<Tokenizer>(Tokenizer.jieba);
const tokenizer2uiLabel = {Tokenizer.jieba: UiLabel("结巴"), Tokenizer.simple: UiLabel("Simple")};

/// [DbManager] 具体实现。
///  - 非 Web 平台： `data\impl\kind.dart`；
///  - Web 平台：`data\impl_web\kind.dart`。
final dbManagerKindProvider = mutable(dbManagerKind2uiLabel.keys.first);
final dbManagerKind2uiLabel = {for (final t in DbManagerKind.values) t: UiLabel(t.name)};

/// 拼音文件
final pinyinDictKindProvider = mutable(PinyinDictKind.bundled);
const pinyinDictKind2uiLabel = {
  PinyinDictKind.bundled: UiLabel("内置 (zdic.txt)", "内置"),
  PinyinDictKind.simpleDefault: UiLabel("原 Simple 扩展内置", "原扩展"),
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
    final _DbBootstrapResult(:dbManager, :pinyinDictKind2path) = await ref.watch(
      _dbBootstrapProvider.future,
    );
    final dao = dbManager.dao;

    /// 切换拼音文件
    final pinyinDictKind = ref.watch(pinyinDictKindProvider);
    await dao.updatePinyinDict(pinyinDictKind2path[pinyinDictKind]!);

    return dbManager;
  }
}

/// 搜索结果
final searchResultProvider = FutureProvider<SearchResultUiModel?>((ref) async {
  if (ref.watch(_dbBootstrapProvider).isLoading) {
    return null;
  }
  final dao = (await ref.watch(dbManagerProvider.future)).dao; // 数据库就绪
  final query = ref.watch(searchQueryProvider).trim(); // 搜索文本
  final tokenizer = ref.watch(tokenizerProvider); // 分词器

  final SearchResult result = query.isEmpty
      ? SearchResult(rows: await dao.selectAll(), tokens: '', elapsed: Duration.zero)
      : await dao.search(query, tokenizer);
  final totalCount = await dao.selectCount();
  return SearchResultUiModel(
    rows: result.rows
        .map(
          (r) => MainTableRowUiModel(
            id: r.id,
            idFormatted: "${r.id}".padLeft("$totalCount".length, "0"),
            title: r.title,
            content: r.content,
            insertDate: r.insertDate,
          ),
        )
        .toList(),
    tokens: result.tokens,
    elapsed: result.elapsed,
    query: query,
    totalCount: totalCount,
  );
});

/// 重新生成随机数据，以测试触发器
Future<void> refreshDbData(WidgetRef ref) async {
  final dbManager = await ref.read(dbManagerProvider.future);
  await dbManager.dao.updateAll();
  ref.invalidate(searchResultProvider);
  await ref.read(searchResultProvider.future);
}
