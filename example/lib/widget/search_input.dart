import 'package:flutter/material.dart';

class SearchInput extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const SearchInput({
    super.key,
    required this.onChanged
  });

  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  late final SearchController _controller;
  var _showClearBtn = false;

  @override
  void initState() {
    super.initState();
    _controller = SearchController();
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      child: SearchBar(
        controller: _controller,
        leading: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Icon(Icons.search),
        ),
        trailing: [
          if (_showClearBtn)
            IconButton(onPressed: _clear, icon: const Icon(Icons.clear)),
        ],
        elevation: const WidgetStatePropertyAll(0),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  void _onChanged() {
    final value = _controller.text;
    setState(() => _showClearBtn = value.isNotEmpty);
    widget.onChanged(value);
  }

  void _clear() {
    _controller.text = '';
  }
}
