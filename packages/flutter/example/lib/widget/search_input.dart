import 'package:flutter/material.dart';

class SearchInput extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final String hintText;

  final ValueChanged<bool>? onFocusChanged;

  const SearchInput({
    super.key,
    required this.onChanged,
    required this.hintText,
    this.onFocusChanged,
  });

  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  late final SearchController _controller;
  late final FocusNode _focusNode;
  var _showClearBtn = false;
  var _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()
      ..addListener(() {
        final focused = _focusNode.hasFocus;
        if (focused != _focused) {
          setState(() => _focused = focused);
          widget.onFocusChanged?.call(focused);
        }
      });
    _controller = SearchController()
      ..addListener(() {
        final value = _controller.text;
        setState(() => _showClearBtn = value.isNotEmpty);
        widget.onChanged(value);
      });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      controller: _controller,
      focusNode: _focusNode,
      constraints: const BoxConstraints(minHeight: 44),
      hintText: widget.hintText,
      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 4)),
      leading: TextFieldTapRegion(child: _Icon(icon: Icons.search, focused: _focused)),
      trailing: [
        if (_showClearBtn)
          TextFieldTapRegion(
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                canRequestFocus: false,
                onTap: _controller.clear,
                borderRadius: BorderRadius.circular(8),
                child: _Icon(icon: Icons.clear, focused: _focused),
              ),
            ),
          ),
      ],
      elevation: const WidgetStatePropertyAll(0),
      backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      shape: const WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
    );
  }
}

class _Icon extends StatelessWidget {
  final IconData icon;
  final bool focused;

  const _Icon({required this.icon, required this.focused});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TweenAnimationBuilder<Color?>(
      duration: kThemeChangeDuration,
      curve: Curves.fastOutSlowIn,
      tween: ColorTween(end: focused ? scheme.primary : scheme.onSurface),
      builder: (context, color, _) =>
          SizedBox.square(dimension: 36.0, child: Icon(icon, color: color, size: 22)),
    );
  }
}
