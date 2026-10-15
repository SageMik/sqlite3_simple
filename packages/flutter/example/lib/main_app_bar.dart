import 'package:flutter/material.dart' as material;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'main_provider.dart';
import 'widget/common_dialog.dart';

class AppBar extends material.AppBar {
  AppBar()
    : super(
        toolbarHeight: 72,
        title: _Title(title: 'Simple 分词器', subtitle: '示例'),
        actions: [
          Consumer(
            builder: (context, ref, _) => IconButton(
              tooltip: '刷新数据',
              onPressed: () => refreshDbData(ref),
              icon: const Icon(Icons.refresh),
            ),
          ),
          Builder(
            builder: (context) => IconButton(
              tooltip: '使用说明',
              onPressed: () =>
                  showDialog(context: context, builder: (context) => const _UsageDialog()),
              icon: const Icon(Icons.info_outline_rounded),
            ),
          ),
          IconButton(
            tooltip: 'Github 仓库',
            onPressed: () => launchUrl(
              Uri.parse('https://github.com/SageMik/sqlite3_simple'),
              webOnlyWindowName: '_blank',
            ),
            icon: const FaIcon(FontAwesomeIcons.github, size: 20),
          ),
        ],
        actionsPadding: const EdgeInsetsDirectional.only(end: 16),
      );
}

class _Title extends StatelessWidget {
  final String title;
  final String subtitle;

  const _Title({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: scheme.primary, borderRadius: BorderRadius.circular(7)),
          child: Text(
            title.characters.first,
            style: TextStyle(
              color: scheme.onPrimary,
              fontSize: 20,
              height: 1,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: IntrinsicWidth(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 3,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  Container(
                    height: 16,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: .10),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      subtitle,
                      style: TextStyle(color: scheme.primary, fontSize: 10, height: 1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _UsageDialog extends StatelessWidget {
  const _UsageDialog();

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
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 4,
          children: [
            const Text(
              '使用说明',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
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
