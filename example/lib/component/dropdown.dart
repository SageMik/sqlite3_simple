import 'package:flutter/material.dart';

class Dropdown<T> extends StatefulWidget {
  final String label;
  final T initValue;
  final Map<T, String> map;
  final ValueChanged<T?> onChanged;

  const Dropdown({
    super.key,
    required this.label,
    required this.initValue,
    required this.map,
    required this.onChanged,
  });

  @override
  State<StatefulWidget> createState() => _DropdownState<T>();
}

class _DropdownState<T> extends State<Dropdown<T>> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(widget.label, style: const TextStyle(fontSize: 16)),
        DropdownButton<T>(
          isDense: true,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          value: widget.initValue,
          items: widget.map.entries
              .map((e) =>
                  DropdownMenuItem<T>(value: e.key, child: Text(e.value)))
              .toList(),
          onChanged: widget.onChanged,
        ),
      ],
    );
  }
}
