// ===== Flutter 3.35.x =====
import 'dart:async'; // for debounce timer
import 'package:flutter/material.dart'; // core UI

// Main reusable, responsive search bar
class AppSearchBar extends StatefulWidget {
  // initial text to show in the field
  final String? initialQuery; // start text
  // hint inside the field when empty
  final String hint; // placeholder
  // called on every text change (debounced if debounceMs > 0)
  final ValueChanged<String>? onQueryChanged; // change callback
  // called when user presses submit/search on keyboard
  final ValueChanged<String>? onSubmitted; // submit callback
  // called when user taps the clear (x) button
  final VoidCallback? onClear; // clear callback
  // optional filter button on the right (e.g. to open filters sheet)
  final VoidCallback? onFilterPressed; // filter action
  // autofocus when widget appears
  final bool autofocus; // auto focus field
  // read only mode (e.g. to open a search page)
  final bool readOnly; // disable typing
  // milliseconds to debounce onQueryChanged (0 = no debounce)
  final int debounceMs; // debounce time
  // outer margin for the whole bar
  final EdgeInsetsGeometry? margin; // external spacing
  // filled background style (true) or just outline (false)
  final bool filled; // filled vs outline
  // shows a back arrow at the start (useful on search pages)
  final bool showBack; // back button toggle
  // back button action (if null, Navigator.pop)
  final VoidCallback? onBack; // custom back action
  // custom border radius
  final double? borderRadius; // corners
  // semantic label for a11y
  final String? semanticLabel; // accessibility label

  const AppSearchBar({
    super.key, // key
    this.initialQuery, // init text
    this.hint = 'Search…', // default hint
    this.onQueryChanged, // change
    this.onSubmitted, // submit
    this.onClear, // clear
    this.onFilterPressed, // filter press
    this.autofocus = false, // no autofocus by default
    this.readOnly = false, // editable by default
    this.debounceMs = 250, // small debounce
    this.margin, // outer margin
    this.filled = true, // filled by default
    this.showBack = false, // no back by default
    this.onBack, // back action
    this.borderRadius, // radius
    this.semanticLabel, // label
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState(); // state
}

class _AppSearchBarState extends State<AppSearchBar> {
  late final TextEditingController _ctrl; // text controller
  late final FocusNode _focus; // focus node
  Timer? _debounce; // debounce timer

  @override
  void initState() {
    super.initState(); // parent
    _ctrl = TextEditingController(text: widget.initialQuery ?? ''); // set text
    _focus = FocusNode(); // create focus
  }

  @override
  void dispose() {
    _debounce?.cancel(); // stop timer
    _ctrl.dispose(); // free controller
    _focus.dispose(); // free focus
    super.dispose(); // parent
  }

  // helper: call onQueryChanged with debounce if needed
  void _handleChanged(String q) {
    // cancel previous timer
    _debounce?.cancel(); // stop old timer
    // no debounce wanted
    if (widget.debounceMs <= 0) {
      widget.onQueryChanged?.call(q); // call immediately
      return; // done
    }
    // start new timer
    _debounce = Timer(Duration(milliseconds: widget.debounceMs), () {
      widget.onQueryChanged?.call(q); // call after delay
    });
    setState(() {}); // update clear button visibility
  }

  // clear text and notify
  void _clear() {
    _ctrl.clear(); // empty field
    widget.onClear?.call(); // external callback
    widget.onQueryChanged?.call(''); // notify change = empty
    setState(() {}); // rebuild (hide clear icon)
    // re-focus field after clear
    if (!widget.readOnly) _focus.requestFocus(); // focus again
  }

  // compute responsive metrics (padding, radius, icon/text sizes)
  ({EdgeInsets pad, double radius, double font, double icon, double height})
  _metrics(BuildContext ctx) {
    final mq = MediaQuery.of(ctx); // media
    final width = mq.size.width; // screen width
    final shortest = mq.size.shortestSide; // phone/tablet
    final textScale = mq.textScaleFactor.clamp(1.0, 1.3); // cap text scale
    final isTablet = shortest >= 600; // simple heuristic
    final widthScale = (width / 390).clamp(0.9, 1.18); // base scale
    final scale = isTablet ? widthScale * 1.06 : widthScale; // small boost

    // base tokens (phone baseline)
    double hPad = 14, vPad = 10, font = 15, icon = 20, radius = 14, height = 48;

    // apply scale
    final pad = EdgeInsets.symmetric(
      horizontal: (hPad * scale).clamp(12, 22), // x padding
      vertical: (vPad * scale).clamp(8, 14), // y padding
    );
    final r = (widget.borderRadius ?? radius * scale)
        .clamp(12, 20)
        .toDouble(); // corners
    final f = (font * scale * textScale).clamp(14, 20).toDouble(); // font size
    final ic = (icon * scale).clamp(18, 24).toDouble(); // icon size
    final h = (height * scale).clamp(44, 56).toDouble(); // bar height

    return (pad: pad, radius: r, font: f, icon: ic, height: h); // tuple
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // theme
    final cs = theme.colorScheme; // colors
    final m = _metrics(context); // responsive sizes

    // colors
    final Color fill = cs.surfaceContainerHighest; // filled bg
    final Color stroke = cs.outlineVariant; // border color
    final Color text =
        theme.textTheme.bodyLarge?.color ?? cs.onSurface; // text color
    final Color hint = cs.onSurface.withOpacity(0.55); // hint color

    // shape
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(m.radius), // corners
      side: BorderSide(color: stroke, width: 1), // 1px border
    );

    // back button (optional)
    final back = widget.showBack
        ? IconButton(
            onPressed:
                widget.onBack ?? () => Navigator.maybePop(context), // go back
            icon: const Icon(Icons.arrow_back), // icon
            iconSize: m.icon, // size
            tooltip: 'Back', // tooltip
          )
        : null; // none

    // clear button (visible only when text not empty)
    final clearVisible = _ctrl.text.isNotEmpty; // show x?
    final clear = clearVisible
        ? IconButton(
            onPressed: _clear, // clear text
            icon: const Icon(Icons.close_rounded), // x icon
            iconSize: m.icon, // size
            tooltip: 'Clear', // tooltip
          )
        : null; // none

    // filter button (optional)
    final filter = widget.onFilterPressed == null
        ? null // no filter
        : IconButton(
            onPressed: widget.onFilterPressed, // open filters
            icon: const Icon(Icons.tune_rounded), // filter icon
            iconSize: m.icon, // size
            tooltip: 'Filters', // tooltip
          );

    // input field (inside decorated container)
    final field = TextField(
      controller: _ctrl, // controller
      focusNode: _focus, // focus
      autofocus: widget.autofocus, // focus on show
      readOnly: widget.readOnly, // read only?
      textInputAction: TextInputAction.search, // show search action
      onChanged: _handleChanged, // debounce change
      onSubmitted: widget.onSubmitted, // submit
      style: theme.textTheme.bodyLarge?.copyWith(
        fontSize: m.font, // responsive font
        color: text, // text color
      ),
      decoration: InputDecoration(
        hintText: widget.hint, // placeholder
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          fontSize: m.font, // match font
          color: hint, // hint color
        ),
        border: InputBorder.none, // no inner border
        isDense: true, // compact
        contentPadding: EdgeInsets.zero, // we pad the container
        prefixIcon: back, // optional back
        prefixIconConstraints: const BoxConstraints(
          minWidth: 0,
          minHeight: 0,
        ), // tighter
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min, // wrap
          children: [
            if (clear != null) clear, // clear button
            if (filter != null) filter, // filter button
          ],
        ), // trailing actions
        suffixIconConstraints: const BoxConstraints(
          minWidth: 0,
          minHeight: 0,
        ), // tight
      ),
    );

    // decorated container holding the field
    Widget bar = Material(
      color: widget.filled ? fill : Colors.transparent, // bg
      shape: shape, // border + radius
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: m.height), // min height
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: m.pad.horizontal / 2,
          ), // inner x pad
          child: Row(
            children: [
              const Icon(Icons.search_rounded), // search icon
              SizedBox(width: (m.font * 0.6).clamp(8, 12)), // small gap
              Expanded(child: field), // the text field
            ],
          ),
        ),
      ),
    );

    // add margin if provided
    if (widget.margin != null) {
      bar = Padding(padding: widget.margin!, child: bar); // outer margin
    }

    // semantics for a11y
    return Semantics(
      label: widget.semanticLabel ?? 'Search', // a11y label
      textField: true, // role
      child: bar, // widget
    );
  }
}

// Convenience: use search bar directly inside an AppBar
class AppSearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  // forward all important props to AppSearchBar
  final String? initialQuery; // init text
  final String hint; // placeholder
  final ValueChanged<String>? onQueryChanged; // change
  final ValueChanged<String>? onSubmitted; // submit
  final VoidCallback? onClear; // clear
  final VoidCallback? onFilterPressed; // filter
  final bool autofocus; // focus on show
  final bool readOnly; // read only
  final int debounceMs; // debounce
  final bool showBack; // back icon
  final VoidCallback? onBack; // back action
  final bool filled; // filled look
  final double? borderRadius; // corners

  const AppSearchAppBar({
    super.key, // key
    this.initialQuery, // init
    this.hint = 'Search…', // hint
    this.onQueryChanged, // change
    this.onSubmitted, // submit
    this.onClear, // clear
    this.onFilterPressed, // filter
    this.autofocus = false, // focus
    this.readOnly = false, // read only
    this.debounceMs = 250, // debounce
    this.showBack = true, // show back in app bar
    this.onBack, // back action
    this.filled = true, // filled
    this.borderRadius, // radius
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight); // appbar height

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // theme
    return AppBar(
      titleSpacing: 0, // no extra spacing
      title: AppSearchBar(
        initialQuery: initialQuery, // init
        hint: hint, // hint
        onQueryChanged: onQueryChanged, // change
        onSubmitted: onSubmitted, // submit
        onClear: onClear, // clear
        onFilterPressed: onFilterPressed, // filter
        autofocus: autofocus, // focus
        readOnly: readOnly, // read only
        debounceMs: debounceMs, // debounce
        showBack: showBack, // back icon
        onBack: onBack, // back action
        filled: filled, // filled look
        borderRadius: borderRadius, // corners
        margin: const EdgeInsets.symmetric(horizontal: 12), // horizontal margin
      ),
      backgroundColor: theme.colorScheme.surface, // app bar bg
      elevation: 0, // flat
    );
  }
}
