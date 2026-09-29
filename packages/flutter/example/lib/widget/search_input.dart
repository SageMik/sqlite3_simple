import 'package:flutter/material.dart';
import 'package:sqlite3_simple_example/utils/padding.dart';

class SearchInput extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final String hintText;

  const SearchInput({super.key, required this.onChanged, required this.hintText});

  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  late final SearchController _controller;
  var _showClearBtn = false;

  @override
  void initState() {
    super.initState();
    _controller = SearchController()
      ..addListener(() {
        final value = _controller.text;
        setState(() => _showClearBtn = value.isNotEmpty);
        widget.onChanged(value);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TapRegion(
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      child: SearchBar(
        controller: _controller,
        constraints: const BoxConstraints(minHeight: 48),
        hintText: widget.hintText,
        leading: const Padding(
          padding: EdgeInsets.symmetric(horizontal: P.extraSmall),
          child: Icon(Icons.search),
        ),
        trailing: [
          if (_showClearBtn)
            IconButton(
              onPressed: () => _controller.text = '',
              icon: const Icon(Icons.clear),
            ),
        ],
        elevation: const WidgetStatePropertyAll(0),
        backgroundColor: WidgetStatePropertyAll(scheme.surfaceContainerLow),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        side: WidgetStateProperty.resolveWith(
          (states) => BorderSide(
            color: states.contains(WidgetState.focused)
                ? scheme.primary
                : Colors.transparent,
            width: states.contains(WidgetState.focused) ? 1.5 : 0,
          ),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(P.small)),
        ),
      ),
    );
  }
}
