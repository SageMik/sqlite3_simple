import 'package:flutter/material.dart';

import '../utils/ui_label.dart';

class ChipRadioGroup<T> extends StatelessWidget {
  final T value;
  final Map<T, UiLabel> options;
  final ValueChanged<T> onSelect;
  final double fontSize;

  const ChipRadioGroup({
    super.key,
    required this.value,
    required this.options,
    required this.onSelect,
    this.fontSize = 13,
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
                color: isSelected
                    ? scheme.primary
                    : scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => onSelect(e.key),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Opacity( // 加粗字体占位避免宽度变化
                          opacity: 0,
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: fontSize,
                              fontWeight: selectedWeight,
                            ),
                          ),
                        ),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: isSelected ? selectedWeight : null,
                            color: isSelected
                                ? scheme.onPrimary
                                : scheme.onSurface,
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
