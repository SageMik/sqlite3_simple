import 'package:flutter/material.dart';

import '../utils/padding.dart';
import 'chip_radio_group.dart';

class SearchOptionRadioRow<T extends Object> extends TableRow {
  final String label;
  final T value;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;
  final bool isLast;

  static const chipFontSize = 12.0;
  static const labelFontSize = 14.0;
  static const topPadding = P.extraSmall + (labelFontSize - chipFontSize) / 2.0;

  SearchOptionRadioRow({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.isLast = false,
  }) : super(
         children: [
           TableCell(
             verticalAlignment: TableCellVerticalAlignment.top,
             child: Padding(
               padding: const EdgeInsets.only(top: topPadding, right: P.small),
               child: Text(
                 label,
                 style: const TextStyle(fontSize: labelFontSize),
               ),
             ),
           ),
           TableCell(
             verticalAlignment: TableCellVerticalAlignment.top,
             child: Padding(
               padding: EdgeInsets.only(bottom: isLast ? 0 : P.small),
               child: ChipRadioGroup<T>(
                 value: value,
                 options: options,
                 onSelect: onChanged,
               ),
             ),
           ),
         ],
       );
}
