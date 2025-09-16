// ===== Flutter 3.35.x =====
// Single-source search widgets with no duplicate back arrows.
// - If showBack=true => ONLY a back icon is shown inside the field.
// - If showBack=false => ONLY a search icon is shown inside the field.
// AppSearchAppBar disables AppBar's default leading to avoid a second arrow.

import 'dart:async';
import 'package:flutter/material.dart';

class AppSearchBar extends StatefulWidget {
  final String? initialQuery;
  final String hint;
  final ValueChanged<String>? onQueryChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final VoidCallback? onFilterPressed;
  final bool autofocus;
  final bool readOnly;
  final int debounceMs;
  final EdgeInsetsGeometry? margin;
  final bool filled;
  final bool showBack;
  final VoidCallback? onBack;
  final double? borderRadius;
  final String? semanticLabel;

  const AppSearchBar({
    super.key,
    this.initialQuery,
    this.hint = 'Search…',
    this.onQueryChanged,
    this.onSubmitted,
    this.onClear,
    this.onFilterPressed,
    this.autofocus = false,
    this.readOnly = false,
    this.debounceMs = 250,
    this.margin,
    this.filled = true,
    this.showBack = false,
    this.onBack,
    this.borderRadius,
    this.semanticLabel,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late final TextEditingController _ctrl;
  late final FocusNode _focus;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialQuery ?? '');
    _focus = FocusNode();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _handleChanged(String q) {
    _debounce?.cancel();
    if (widget.debounceMs <= 0) {
      widget.onQueryChanged?.call(q);
      return;
    }
    _debounce = Timer(Duration(milliseconds: widget.debounceMs), () {
      widget.onQueryChanged?.call(q);
    });
    setState(() {}); // update clear icon visibility
  }

  void _clear() {
    _ctrl.clear();
    widget.onClear?.call();
    widget.onQueryChanged?.call('');
    setState(() {});
    if (!widget.readOnly) _focus.requestFocus();
  }

  ({EdgeInsets pad, double radius, double font, double icon, double height})
  _metrics(BuildContext ctx) {
    final mq = MediaQuery.of(ctx);
    final width = mq.size.width;
    final shortest = mq.size.shortestSide;
    final textScale = mq.textScaleFactor.clamp(1.0, 1.3);
    final isTablet = shortest >= 600;
    final widthScale = (width / 390).clamp(0.9, 1.18);
    final scale = isTablet ? widthScale * 1.06 : widthScale;

    double hPad = 14, vPad = 10, font = 15, icon = 20, radius = 14, height = 48;

    final pad = EdgeInsets.symmetric(
      horizontal: (hPad * scale).clamp(12, 22),
      vertical: (vPad * scale).clamp(8, 14),
    );
    final r = (widget.borderRadius ?? radius * scale).clamp(12, 20).toDouble();
    final f = (font * scale * textScale).clamp(14, 20).toDouble();
    final ic = (icon * scale).clamp(18, 24).toDouble();
    final h = (height * scale).clamp(44, 56).toDouble();

    return (pad: pad, radius: r, font: f, icon: ic, height: h);
  }

  Widget? _buildPrefixIcon(BuildContext context, double iconSize) {
    final cs = Theme.of(context).colorScheme;
    final pad = EdgeInsets.symmetric(horizontal: (iconSize * 0.5).clamp(8, 12));

    if (widget.showBack) {
      return InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: widget.onBack ?? () => Navigator.maybePop(context),
        child: Padding(
          padding: pad,
          child: Icon(Icons.arrow_back, size: iconSize, color: cs.onSurface),
        ),
      );
    }

    return Padding(
      padding: pad,
      child: Icon(
        Icons.search_rounded,
        size: iconSize,
        color: cs.onSurfaceVariant,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final m = _metrics(context);

    final Color fill = cs.surfaceContainerHighest;
    final Color stroke = cs.outlineVariant;
    final Color text = theme.textTheme.bodyLarge?.color ?? cs.onSurface;
    final Color hint = cs.onSurface.withOpacity(0.55);

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(m.radius),
      side: BorderSide(color: stroke, width: 1),
    );

    final clearVisible = _ctrl.text.isNotEmpty;
    final Widget? clear = clearVisible
        ? IconButton(
            onPressed: _clear,
            icon: const Icon(Icons.close_rounded),
            iconSize: m.icon,
            tooltip: 'Clear',
          )
        : null;

    final Widget? filter = widget.onFilterPressed == null
        ? null
        : IconButton(
            onPressed: widget.onFilterPressed,
            icon: const Icon(Icons.tune_rounded),
            iconSize: m.icon,
            tooltip: 'Filters',
          );

    final field = TextField(
      controller: _ctrl,
      focusNode: _focus,
      autofocus: widget.autofocus,
      readOnly: widget.readOnly,
      textInputAction: TextInputAction.search,
      onChanged: _handleChanged,
      onSubmitted: widget.onSubmitted,
      style: theme.textTheme.bodyLarge?.copyWith(fontSize: m.font, color: text),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          fontSize: m.font,
          color: hint,
        ),
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
        // >>> Only ONE leading icon (back OR search)
        prefixIcon: _buildPrefixIcon(context, m.icon),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        // Trailing actions
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [if (clear != null) clear, if (filter != null) filter],
        ),
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      ),
    );

    Widget bar = Material(
      color: widget.filled ? fill : Colors.transparent,
      shape: shape,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: m.height),
        child: Padding(
          // inner horizontal padding for the whole field
          padding: EdgeInsets.symmetric(horizontal: m.pad.horizontal / 2),
          child: field,
        ),
      ),
    );

    if (widget.margin != null) {
      bar = Padding(padding: widget.margin!, child: bar);
    }

    return Semantics(
      label: widget.semanticLabel ?? 'Search',
      textField: true,
      child: bar,
    );
  }
}

// Convenience: Search bar embedded inside an AppBar.
class AppSearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? initialQuery;
  final String hint;
  final ValueChanged<String>? onQueryChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final VoidCallback? onFilterPressed;
  final bool autofocus;
  final bool readOnly;
  final int debounceMs;
  final bool showBack;
  final VoidCallback? onBack;
  final bool filled;
  final double? borderRadius;

  const AppSearchAppBar({
    super.key,
    this.initialQuery,
    this.hint = 'Search…',
    this.onQueryChanged,
    this.onSubmitted,
    this.onClear,
    this.onFilterPressed,
    this.autofocus = false,
    this.readOnly = false,
    this.debounceMs = 250,
    this.showBack = true,
    this.onBack,
    this.filled = true,
    this.borderRadius,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      // <<< IMPORTANT: prevent AppBar from adding an extra leading back arrow
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: AppSearchBar(
        initialQuery: initialQuery,
        hint: hint,
        onQueryChanged: onQueryChanged,
        onSubmitted: onSubmitted,
        onClear: onClear,
        onFilterPressed: onFilterPressed,
        autofocus: autofocus,
        readOnly: readOnly,
        debounceMs: debounceMs,
        showBack: showBack, // shows ONE back icon inside the field
        onBack: onBack,
        filled: filled,
        borderRadius: borderRadius,
        margin: const EdgeInsets.symmetric(horizontal: 12),
      ),
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
    );
  }
}
