import 'package:flutter/material.dart';

import '../utils/ui_label.dart';

class SearchOptions extends StatefulWidget {
  final List<SearchOptionRow> rows;

  const SearchOptions({super.key, required this.rows});

  @override
  State<SearchOptions> createState() => _SearchOptionsState();
}

class _SearchOptionsState extends State<SearchOptions> with SingleTickerProviderStateMixin {
  late final _expandController = AnimationController(
    vsync: this,
    duration: kThemeAnimationDuration,
    value: 1,
  );
  late final _expandAnimation = CurvedAnimation(parent: _expandController, curve: Curves.easeInOut);

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final edge = BorderSide(color: scheme.surfaceContainerLow);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.surfaceContainerLow),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (_expandController.isCompleted) {
                _expandController.reverse();
              } else {
                _expandController.forward();
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                spacing: 8,
                children: [
                  Text('选项', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                  Expanded(
                    child: Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 4,
                      runSpacing: 8,
                      children: [for (final row in widget.rows) _BadgePill(label: row.pillLabel)],
                    ),
                  ),
                  RotationTransition(
                    turns: Tween(begin: 0.0, end: 0.5).animate(_expandAnimation),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 18,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _expandAnimation,
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                Divider(height: 1, color: edge.color),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Table(
                    columnWidths: const {0: IntrinsicColumnWidth(), 1: FlexColumnWidth()},
                    children: widget.rows,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgePill extends StatelessWidget {
  final String label;

  const _BadgePill({required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEEFF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: scheme.primary),
      ),
    );
  }
}

class SearchOptionRow<T extends Object> extends TableRow {
  final String label;
  final T value;
  final Map<T, UiLabel> options;
  final ValueChanged<T> onChanged;

  String get pillLabel => options[value]!.short;

  SearchOptionRow({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  }) : super(
         children: [
           TableCell(
             verticalAlignment: TableCellVerticalAlignment.middle,
             child: Padding(
               padding: const EdgeInsets.only(right: 8),
               child: Text(label, style: const TextStyle(fontSize: 12)),
             ),
           ),
           TableCell(
             verticalAlignment: TableCellVerticalAlignment.middle,
             child: Padding(
               padding: const EdgeInsets.symmetric(vertical: 4),
               child: _OptionChips<T>(value: value, options: options, onSelect: onChanged),
             ),
           ),
         ],
       );
}

class _OptionChips<T> extends StatelessWidget {
  final T value;
  final Map<T, UiLabel> options;
  final ValueChanged<T> onSelect;
  final double fontSize;

  const _OptionChips({
    super.key,
    required this.value,
    required this.options,
    required this.onSelect,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const selectedWeight = FontWeight.bold;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.entries.map((e) {
              final label = e.value.full;
              final isSelected = value == e.key;
              return Material(
                color: isSelected ? scheme.primary : scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => onSelect(e.key),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Opacity(
                          // 加粗字体占位避免宽度变化
                          opacity: 0,
                          child: Text(
                            label,
                            style: TextStyle(fontSize: fontSize, fontWeight: selectedWeight),
                          ),
                        ),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: isSelected ? selectedWeight : null,
                            color: isSelected ? scheme.onPrimary : scheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
