import 'main_table_dao.dart';
import 'pinyin_dict_kind.dart';

abstract class IDbManager<TDb> {

  /// 初始化数据库
  Future<void> init();

  /// 保存拼音文件到可访问的路径
  Future<Map<PinyinDictKind, String>> savePinyinDict();

  /// 关闭数据库
  Future<void> close();
}

abstract class DbManager<TDao extends MainTableDao, TDb> implements IDbManager<TDb> {
  abstract final TDao dao;
}