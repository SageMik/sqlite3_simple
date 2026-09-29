import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sqlite3_simple_example/widget/dialog/usage_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

import 'main_provider.dart';
import 'utils/padding.dart';

class SimpleExampleAppBar extends AppBar {
  SimpleExampleAppBar({super.key})
    : super(
        toolbarHeight: 64,
        title: _Title(title: 'Simple 分词器', subtitle: '示例'),
        actions: [
          Consumer(
            builder: (context, ref, _) => IconButton(
              constraints: _iconConstraints,
              tooltip: '刷新数据',
              onPressed: () => refreshDbData(ref),
              icon: const Icon(Icons.refresh),
            ),
          ),
          Builder(
            builder: (context) => IconButton(
              constraints: _iconConstraints,
              tooltip: '使用说明',
              onPressed: () =>
                  showDialog(context: context, builder: (context) => const UsageDialog()),
              icon: const Icon(Icons.info_outline_rounded),
            ),
          ),
          IconButton(
            constraints: _iconConstraints,
            tooltip: 'Github 仓库',
            onPressed: () => launchUrl(
              Uri.parse('https://github.com/SageMik/sqlite3_simple'),
              webOnlyWindowName: '_blank',
            ),
            icon: const FaIcon(FontAwesomeIcons.github, size: 20),
          ),
        ],
        actionsPadding: const EdgeInsetsDirectional.only(end: P.small),
      );
}

const BoxConstraints _iconConstraints = BoxConstraints(minWidth: 48, minHeight: 48);

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
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: scheme.primary, borderRadius: BorderRadius.circular(7)),
          child: Text(
            title.characters.first,
            style: TextStyle(color: scheme.onPrimary, fontSize: 14, height: 1),
          ),
        ),
        const SizedBox(width: P.small),
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
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  Container(
                    height: 14,
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
