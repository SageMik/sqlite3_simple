import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/db_manager.dart';
import 'data/db_manager_kind.dart';
import 'data/main_table_dao.dart';
import 'data/main_table_row.dart';
import 'data/modifiable_notifier.dart';

/// 搜索文本
final searchQueryProvider = mutable<String>("");

/// 分词器
final tokenizerProvider = mutable<Tokenizer>(Tokenizer.jieba);
const tokenizer2uiString = {Tokenizer.jieba: "结巴", Tokenizer.simple: "Simple"};
final kind2uiString = {for (final t in DbManagerKind.values) t: t.name};

/// [DbManager] 具体实现。
///  - 非 Web 平台： `data\impl\kind.dart`；
///  - Web 平台：`dart\impl_web\kind.dart`。
final dbManagerKindProvider = mutable(kind2uiString.keys.first);

/// [DbManager] 数据库管理类
final dbManagerProvider = AsyncNotifierProvider(DbManagerNotifier.new);

class DbManagerNotifier extends AsyncNotifier<DbManager> {
  @override
  Future<DbManager> build() async {
    final kind = ref.watch(dbManagerKindProvider);
    final dbManager = DbManager.create(kind);
    ref.onDispose(dbManager.close); // 如果初始化抛出异常，调用 `close` 可能触发 `dao` 未初始化报错
    await dbManager.init();
    await dbManager.dao.insertRandomData(30);
    return dbManager;
  }
}

/// 搜索结果
final searchResultProvider = FutureProvider<List<MainTableRowUiModel>?>((
  ref,
) async {
  if (ref.watch(dbManagerProvider).isLoading) {
    return null;
  }
  final dbManager = await ref.watch(dbManagerProvider.future);
  final query = ref.watch(searchQueryProvider);
  final tokenizer = ref.watch(tokenizerProvider);

  final dao = dbManager.dao;
  final rows = query.isEmpty
      ? await dao.selectAll()
      : await dao.search(query.trim(), tokenizer);
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
