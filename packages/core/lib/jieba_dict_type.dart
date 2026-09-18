/// 结巴分词所需的字典文件，每个字典文件视为一个类型，详见 [simple_tokenizer.cc](https://github.com/wangfenjin/simple/blob/4ed008934495fc55ff4bf6620bba58311988b23e/src/simple_tokenizer.cc#L96-L98) 。
enum JiebaDictType {
  jiebaDict("jieba.dict.utf8"),
  hmmModel("hmm_model.utf8"),
  userDict("user.dict.utf8"),
  idf("idf.utf8"),
  stopWords("stop_words.utf8");

  const JiebaDictType(this.filename);

  /// 文件名
  final String filename;

  /// [filename] 到 [JiebaDictType] 的映射
  static final Map<String, JiebaDictType> byFilename = Map.unmodifiable({
    for (final k in values) k.filename: k,
  });
}