import 'package:flutter/material.dart';

import '../utils/padding.dart';

class ChipRadioGroup<T> extends StatelessWidget {
  final T value;
  final Map<T, String> options;
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
            spacing: P.small,
            runSpacing: P.small,
            children: options.entries.map((e) {
              final isSelected = value == e.key;
              return Material(
                color: isSelected
                    ? scheme.primary
                    : scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(P.small),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => onSelect(e.key),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: P.middle,
                      vertical: P.small * .8,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Opacity( // 加粗字体占位避免宽度变化
                          opacity: 0,
                          child: Text(
                            e.value,
                            style: TextStyle(
                              fontSize: fontSize,
                              fontWeight: selectedWeight,
                            ),
                          ),
                        ),
                        Text(
                          e.value,
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
