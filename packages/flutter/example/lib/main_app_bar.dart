import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sqlite3_simple_example/widget/dialog/usage_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

import 'main_provider.dart';

class SimpleExampleAppBar extends AppBar {
  SimpleExampleAppBar({super.key})
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
                  showDialog(context: context, builder: (context) => const UsageDialog()),
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
            style: TextStyle(color: scheme.onPrimary, fontSize: 20, height: 1, fontWeight: FontWeight.bold),
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
