import 'package:meta/meta.dart';

import 'main_table_dao.dart';
import 'pinyin_dict_kind.dart';

abstract class IDbManager<TDb> {

  /// 初始化数据库
  Future<void> init();

  /// 创建主表、FTS5 虚表及其触发器，官方说明：https://sqlite.org/fts5.html
  @protected
  Future<void> createMainAndFts5(TDb db);

  /// 保存拼音文件到可访问的路径
  Future<Map<PinyinDictKind, String>> savePinyinDict();

  /// 关闭数据库
  Future<void> close();
}

abstract class DbManager<TDao extends MainTableDao, TDb> implements IDbManager<TDb> {
  abstract final TDao dao;
}