import 'package:flutter/material.dart';

import '../../utils/padding.dart';
import 'common_dialog.dart';

/// 使用说明对话框
class UsageDialog extends StatelessWidget {
  const UsageDialog({super.key});

  static const _usage = '''
点击右上角刷新按钮，或重复点击已选中的数据库实现，可以刷新数据库数据。

结巴分词 和 Simple 分词 的差异之一是对 `C#` 的分词逻辑不同，可搜索后切换分词器查看。

原 Simple 扩展内置的拼音字典包含了很多不常见的古音（如 `示(U+793A, qí)`、`客(U+5BA2, qià)` 等），可搜索 `qili`（示例）后切换拼音文件以查看差异。''';

  @override
  Widget build(BuildContext context) {
    final maxBodyHeight = MediaQuery.sizeOf(context).height * 0.55;
    return CommonDialog(
      closeLabel: '关闭',
      child: Padding(
        padding: const EdgeInsets.all(P.extraSmall),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: P.extraSmall,
          children: [
            const Text(
              '使用说明',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: P.small),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxBodyHeight),
              child: const SingleChildScrollView(
                child: Text(_usage, style: TextStyle(fontSize: 16, height: 1.3)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
