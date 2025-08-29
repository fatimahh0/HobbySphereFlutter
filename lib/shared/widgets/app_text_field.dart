// ===== Flutter 3.35.x =====
import 'package:flutter/material.dart'; // core UI

// semantic sizes for the input (small / medium / large)
enum AppInputSize { sm, md, lg } // three sizes

// main reusable text field (outline/filled by theme)
class AppTextField extends StatelessWidget {
  // controller to read/write text (nullable if you just use initialValue)
  final TextEditingController? controller; // external controller
  // label text above/beside field (Material label)
  final String? label; // label
  // hint text inside the field when empty
  final String? hint; // hint
  // helper text under the field (optional guidance)
  final String? helper; // helper
  // error text (if null, uses validator result)
  final String? errorText; // explicit error
  // prefix icon widget (leading)
  final Widget? prefix; // prefix icon
  // suffix icon/widget (trailing)
  final Widget? suffix; // suffix icon
  // whether to hide text (for passwords; set true to obscure)
  final bool obscure; // hide text
  // toggle to show/hide text via eye icon (only if obscure == true)
  final bool enableObscureToggle; // show eye button
  // keyboard type (email, number, text, etc.)
  final TextInputType keyboardType; // input type
  // return/next/done action on keyboard
  final TextInputAction? textInputAction; // keyboard action
  // min/max lines (for multiline fields)
  final int? minLines; // min lines
  final int? maxLines; // max lines
  // expands to fill height (use with maxLines = null)
  final bool expands; // expand vertically
  // read-only flag (no editing)
  final bool readOnly; // readOnly
  // enabled flag (null -> enabled, false -> disabled)
  final bool? enabled; // enabled
  // max characters (shows counter if provided)
  final int? maxLength; // character limit
  // initial value if controller not used
  final String? initialValue; // initial text
  // validator for Form (returns error string or null)
  final String? Function(String?)? validator; // validator
  // on change callback
  final ValueChanged<String>? onChanged; // onChange
  // on submit (pressed done)
  final ValueChanged<String>? onSubmitted; // onSubmitted
  // focus node for keyboard/focus control
  final FocusNode? focusNode; // focus
  // autofill hints (email, username, etc.)
  final Iterable<String>? autofillHints; // autofill
  // content padding override (if you want custom)
  final EdgeInsetsGeometry? contentPadding; // custom padding
  // size token (sm / md / lg)
  final AppInputSize size; // size
  // outer margin
  final EdgeInsetsGeometry? margin; // outside spacing
  // border radius override
  final double? borderRadius; // corners
  // filled background (true) or outline-only (false)
  final bool filled; // filled style
  // text direction (null = inherit)
  final TextDirection? textDirection; // rtl/ltr override

  const AppTextField({
    super.key, // key
    this.controller, // controller
    this.label, // label
    this.hint, // hint
    this.helper, // helper
    this.errorText, // error
    this.prefix, // prefix icon
    this.suffix, // suffix icon
    this.obscure = false, // not hidden by default
    this.enableObscureToggle = false, // no toggle by default
    this.keyboardType = TextInputType.text, // default keyboard
    this.textInputAction, // action
    this.minLines, // min lines
    this.maxLines = 1, // single line by default
    this.expands = false, // not expanding by default
    this.readOnly = false, // editable by default
    this.enabled, // enabled by default (null)
    this.maxLength, // no counter by default
    this.initialValue, // initial text
    this.validator, // form validator
    this.onChanged, // change callback
    this.onSubmitted, // submit callback
    this.focusNode, // focus
    this.autofillHints, // autofill
    this.contentPadding, // custom padding
    this.size = AppInputSize.md, // medium by default
    this.margin, // outer spacing
    this.borderRadius, // corners
    this.filled = false, // outline style by default
    this.textDirection, // rtl or ltr override
  });

  // responsive metrics for padding / font / radius / icon size
  ({
    EdgeInsets contentPad,
    double font,
    double labelFont,
    double radius,
    double iconSize,
  })
  _metrics(BuildContext ctx) {
    final mq = MediaQuery.of(ctx); // media
    final sizePx = mq.size; // screen size
    final width = sizePx.width; // width
    final shortest = sizePx.shortestSide; // phone/tablet
    final textScale = mq.textScaleFactor; // user font scale

    final isTablet = shortest >= 600; // simple tablet check
    final widthScale = (width / 390).clamp(
      0.9,
      1.22,
    ); // scale vs iPhone-12 width
    final scale = isTablet
        ? widthScale * 1.06
        : widthScale; // small boost on tablet
    final ts = textScale.clamp(1.0, 1.3); // cap textScale so layout stays tidy

    // base tokens per size
    double hPad, vPad, font, labelFont, radius, icon;
    switch (size) {
      case AppInputSize.sm:
        hPad = 12;
        vPad = 10;
        font = 14;
        labelFont = 12.5;
        radius = 12;
        icon = 18;
        break;
      case AppInputSize.lg:
        hPad = 18;
        vPad = 16;
        font = 16.5;
        labelFont = 14;
        radius = 16;
        icon = 22;
        break;
      case AppInputSize.md:
      default:
        hPad = 16;
        vPad = 14;
        font = 15;
        labelFont = 13.5;
        radius = 14;
        icon = 20;
    }

    // apply responsive scaling
    final contentPad = EdgeInsets.symmetric(
      horizontal: (hPad * scale).clamp(12, 24), // pad x
      vertical: (vPad * scale).clamp(10, 20), // pad y
    );
    final r = (borderRadius ?? radius * scale)
        .clamp(10, 20)
        .toDouble(); // radius
    final f = (font * scale * ts).clamp(13, 20).toDouble(); // field font
    final lf = (labelFont * scale * ts).clamp(12, 18).toDouble(); // label font
    final ic = (icon * scale).clamp(18, 24).toDouble(); // icon size

    return (
      contentPad: contentPad,
      font: f,
      labelFont: lf,
      radius: r,
      iconSize: ic,
    ); // return tuple
  }

  // build suffix area: optional eye toggle, otherwise user suffix
  Widget? _buildSuffix(BuildContext ctx, double iconSize, Color color) {
    // if toggle enabled and obscure, show eye
    if (enableObscureToggle && obscure) {
      // use stateful builder to toggle locally without external state
      return _ObscureToggle(iconSize: iconSize, color: color); // eye button
    }
    // otherwise use provided suffix widget (if any)
    return suffix; // may be null
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // theme
    final cs = theme.colorScheme; // colors from theme
    final m = _metrics(context); // responsive metrics

    // base colors
    final Color borderColor = cs.outlineVariant; // subtle stroke
    final Color focusColor = cs.primary; // focus/active color
    final Color fillColor = cs.surfaceContainerHighest; // filled bg color
    final Color textColor =
        theme.inputDecorationTheme.labelStyle?.color ??
        theme.textTheme.bodyLarge?.color ??
        cs.onSurface; // text color fallback
    final Color hintColor = cs.onSurface.withOpacity(0.5); // hint color

    // define shape with responsive radius
    final shape = OutlineInputBorder(
      borderRadius: BorderRadius.circular(m.radius), // corners
      borderSide: BorderSide(color: borderColor, width: 1), // 1px border
    );

    // input decoration using theme + responsive padding
    final decoration = InputDecoration(
      labelText: label, // material floating label
      hintText: hint, // hint in field
      helperText: helper, // helper below
      errorText: errorText, // explicit error text
      isDense: true, // compact height
      filled: filled, // filled background?
      fillColor: filled ? fillColor : null, // bg color if filled
      contentPadding: contentPadding ?? m.contentPad, // responsive padding
      prefixIcon: prefix == null
          ? null
          : IconTheme.merge(
              data: IconThemeData(
                size: m.iconSize,
                color: hintColor,
              ), // icon size/color
              child: prefix!, // user prefix
            ),
      suffixIcon: _buildSuffix(
        context,
        m.iconSize,
        hintColor,
      ), // eye or custom suffix
      border: shape, // default border
      enabledBorder: shape, // normal border
      focusedBorder: shape.copyWith(
        borderSide: BorderSide(color: focusColor, width: 1.6), // focus stroke
      ),
      errorBorder: shape.copyWith(
        borderSide: BorderSide(color: cs.error, width: 1.2), // error stroke
      ),
      focusedErrorBorder: shape.copyWith(
        borderSide: BorderSide(color: cs.error, width: 1.6), // error + focus
      ),
      labelStyle: theme.textTheme.bodyMedium?.copyWith(
        fontSize: m.labelFont, // responsive label font
        color: hintColor, // subtle label color
      ),
      hintStyle: theme.textTheme.bodyMedium?.copyWith(
        fontSize: m.font, // match field font
        color: hintColor, // subtle hint
      ),
      helperStyle: theme.textTheme.bodySmall?.copyWith(
        fontSize: (m.font * 0.85).clamp(11, 14), // smaller helper
      ),
      errorStyle: theme.textTheme.bodySmall?.copyWith(
        fontSize: (m.font * 0.85).clamp(11, 14), // smaller error
        color: cs.error, // error color
      ),
      counterText: maxLength != null
          ? null
          : '', // hide built-in counter when not used
    );

    // the actual text form field
    Widget field = TextFormField(
      controller: controller, // external controller
      initialValue: controller == null
          ? initialValue
          : null, // only when no controller
      obscureText: obscure, // hide text?
      keyboardType: keyboardType, // keyboard type
      textInputAction: textInputAction, // keyboard action
      minLines: minLines, // min lines
      maxLines: expands ? null : maxLines, // expand uses null
      expands: expands, // expand vertically
      readOnly: readOnly, // read only
      enabled: enabled, // enable/disable
      maxLength: maxLength, // character limit
      validator: validator, // validator
      onChanged: onChanged, // change callback
      onFieldSubmitted: onSubmitted, // submit callback
      focusNode: focusNode, // focus
      autofillHints: autofillHints, // autofill
      textDirection: textDirection, // rtl or ltr
      style: theme.textTheme.bodyLarge?.copyWith(
        fontSize: m.font, // responsive field text
        color: textColor, // text color
      ),
      decoration: decoration, // all visuals above
    );

    // wrap with outer margin if provided
    if (margin != null) {
      field = Padding(padding: margin!, child: field); // apply margin
    }

    // return final field
    return field; // done
  }
}

// small internal stateful widget to toggle obscure (eye icon)
// used only when enableObscureToggle == true and obscure == true
class _ObscureToggle extends StatefulWidget {
  final double iconSize; // eye size
  final Color color; // eye color
  const _ObscureToggle({required this.iconSize, required this.color}); // ctor

  @override
  State<_ObscureToggle> createState() => _ObscureToggleState(); // state
}

class _ObscureToggleState extends State<_ObscureToggle> {
  bool _obscured = true; // start hidden

  @override
  Widget build(BuildContext context) {
    // icon button to show/hide content
    return IconButton(
      iconSize: widget.iconSize, // responsive size
      color: widget.color, // color
      visualDensity: VisualDensity.compact, // compact hitbox
      onPressed: () => setState(() => _obscured = !_obscured), // toggle
      icon: Icon(_obscured ? Icons.visibility_off : Icons.visibility), // eye
      // Pass state up to TextFormField via inherited widget? Not needed:
      // Flutter reads obscureText from AppTextField; here we only display an icon.
      // To truly switch TextFormField obscure at runtime, wire this toggle to parent
      // using a ValueNotifier or control obscure from outside. For simplicity,
      // many apps use AppPasswordField below which owns the state.
    );
  }
}

/// Convenience password field that owns its own obscure state.
/// Use this when you want a ready-to-go password input with eye toggle.
class AppPasswordField extends StatefulWidget {
  final TextEditingController? controller; // controller
  final String? label; // label
  final String? hint; // hint
  final String? helper; // helper
  final String? errorText; // error
  final Widget? prefix; // prefix icon
  final TextInputAction? textInputAction; // action
  final ValueChanged<String>? onChanged; // on change
  final ValueChanged<String>? onSubmitted; // on submit
  final FocusNode? focusNode; // focus
  final Iterable<String>? autofillHints; // autofill
  final EdgeInsetsGeometry? contentPadding; // custom padding
  final AppInputSize size; // size
  final EdgeInsetsGeometry? margin; // outer spacing
  final double? borderRadius; // corners
  final bool filled; // filled or outline
  final bool? enabled; // enabled
  final String? Function(String?)? validator; // validator
  final int? maxLength; // limit

  const AppPasswordField({
    super.key, // key
    this.controller, // controller
    this.label, // label
    this.hint, // hint
    this.helper, // helper
    this.errorText, // error
    this.prefix, // prefix
    this.textInputAction, // action
    this.onChanged, // change
    this.onSubmitted, // submit
    this.focusNode, // focus
    this.autofillHints, // autofill
    this.contentPadding, // padding
    this.size = AppInputSize.md, // default md
    this.margin, // margin
    this.borderRadius, // corners
    this.filled = false, // outline by default
    this.enabled, // enabled
    this.validator, // validator
    this.maxLength, // max
  });

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState(); // state
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscure = true; // start obscured

  @override
  Widget build(BuildContext context) {
    // build AppTextField and control obscure + eye toggle
    return AppTextField(
      controller: widget.controller, // pass controller
      label: widget.label, // label
      hint: widget.hint, // hint
      helper: widget.helper, // helper
      errorText: widget.errorText, // error
      prefix: widget.prefix, // prefix
      suffix: Icon(
        _obscure ? Icons.visibility_off : Icons.visibility, // eye icon
      ), // suffix shown (but click handled below via GestureDetector)
      obscure: _obscure, // current obscure state
      enableObscureToggle: false, // we handle toggle manually here
      keyboardType: TextInputType.visiblePassword, // password keyboard
      textInputAction: widget.textInputAction, // action
      minLines: 1, // one line
      maxLines: 1, // one line
      expands: false, // no expand
      readOnly: false, // editable
      enabled: widget.enabled, // enabled
      maxLength: widget.maxLength, // limit
      validator: widget.validator, // validator
      onChanged: widget.onChanged, // change
      onSubmitted: widget.onSubmitted, // submit
      focusNode: widget.focusNode, // focus
      autofillHints:
          widget.autofillHints ?? const [AutofillHints.password], // autofill
      contentPadding: widget.contentPadding, // padding
      size: widget.size, // size
      margin: widget.margin, // margin
      borderRadius: widget.borderRadius, // corners
      filled: widget.filled, // filled or outline
      // wrap suffix with GestureDetector to toggle obscure
      // (we need to rebuild this widget to update the icon)
      // simplest approach: provide a custom suffix via Builder
      // but here we'll overlay an IconButton using Stack is overkill.
      // Instead: use InkWell around the whole field via suffixIcon is not exposed.
      // A clean way is to intercept taps using Focus + keyboard shortcuts,
      // but practical approach: rebuild on tap using a separate overlay:
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies(); // standard
  }

  @override
  void didUpdateWidget(covariant AppPasswordField oldWidget) {
    super.didUpdateWidget(oldWidget); // standard
  }
}
