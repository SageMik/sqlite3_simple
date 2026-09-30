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
  late final FocusNode _focusNode;
  var _showClearBtn = false;
  var _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()
      ..addListener(() {
        final focused = _focusNode.hasFocus;
        if (focused != _focused) setState(() => _focused = focused);
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
    final scheme = Theme.of(context).colorScheme;
    return TapRegion(
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      child: SearchBar(
        controller: _controller,
        focusNode: _focusNode,
        constraints: const BoxConstraints(minHeight: 48),
        hintText: widget.hintText,
        padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: P.extraSmall)),
        leading: TextFieldTapRegion(
          child: _Icon(icon: Icons.search, focused: _focused),
        ),
        trailing: [
          if (_showClearBtn)
            // 防止桌面端点击后搜索框失去焦点
            TextFieldTapRegion(
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  canRequestFocus: false,
                  onTap: _controller.clear,
                  borderRadius: BorderRadius.circular(P.small),
                  child: _Icon(icon: Icons.clear, focused: _focused),
                ),
              ),
            ),
        ],
        elevation: const WidgetStatePropertyAll(0),
        backgroundColor: WidgetStatePropertyAll(scheme.surfaceContainerLow),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        side: WidgetStateProperty.resolveWith(
          (states) => BorderSide(
            color: states.contains(WidgetState.focused) ? scheme.primary : Colors.transparent,
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
          SizedBox.square(dimension: 42, child: Icon(icon, color: color)),
    );
  }
}
