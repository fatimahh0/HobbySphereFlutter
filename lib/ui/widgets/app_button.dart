// ===== Flutter 3.35.x =====
import 'package:flutter/material.dart'; // core Flutter UI

// button variants (visual styles)
enum AppButtonType { primary, secondary, outline, text } // 4 variants

// button sizes (semantic sizes)
enum AppButtonSize { sm, md, lg } // 3 sizes

// a single responsive, theme-aware button used across the app
class AppButton extends StatelessWidget {
  // text label (nullable to allow icon-only)
  final String? label; // button text
  // tap callback (null means disabled)
  final VoidCallback? onPressed; // action
  // visual style
  final AppButtonType type; // variant
  // semantic size
  final AppButtonSize size; // size
  // full-width if true
  final bool expand; // stretch horizontally
  // show spinner instead of content
  final bool isBusy; // loading state
  // leading icon widget
  final Widget? leading; // left icon
  // trailing icon widget
  final Widget? trailing; // right icon
  // external spacing around the button
  final EdgeInsetsGeometry? margin; // outer padding
  // optional text style override
  final TextStyle? textStyle; // custom typography
  // corner radius override
  final double? borderRadius; // corners
  // focus node (a11y/keyboard)
  final FocusNode? focusNode; // focus
  // screen reader label
  final String? semanticLabel; // accessibility label

  const AppButton({
    super.key, // widget key
    required this.onPressed, // action (nullable)
    this.label, // optional text
    this.type = AppButtonType.primary, // default: primary fill
    this.size = AppButtonSize.md, // default: medium
    this.expand = false, // not full width by default
    this.isBusy = false, // not loading by default
    this.leading, // optional icon
    this.trailing, // optional icon
    this.margin, // outer spacing
    this.textStyle, // custom text style
    this.borderRadius, // override radius
    this.focusNode, // focus
    this.semanticLabel, // a11y label
  });

  // ===== responsive metrics (padding / font / spinner / min height / radius) =====
  ({
    EdgeInsets padding,
    double font,
    double spinner,
    double minHeight,
    double radius,
  })
  _metrics(BuildContext ctx) {
    // screen info
    final mq = MediaQuery.of(ctx); // media query
    final size = mq.size; // screen size
    final shortest = size.shortestSide; // phone vs tablet
    final width = size.width; // width
    final textScale = mq.textScaleFactor; // user font scale

    // base scale from width (390 is iPhone 12-ish width)
    final widthScale = (width / 390).clamp(0.9, 1.2); // clamp so it stays nice

    // cap text scale slightly (avoid blowing layout)
    final layoutTextScale = textScale.clamp(
      1.0,
      1.3,
    ); // allow a bit larger text

    // detect tablet by shortestSide
    final bool isTablet = shortest >= 600; // rough heuristic

    // base tokens by semantic size (values tuned for phone baseline)
    double baseH, baseV, baseFont, baseSpinner, baseMinH, baseRadius;
    switch (sizeEnumToString(this.size)) {
      case 'sm':
        baseH = 12;
        baseV = 10;
        baseFont = 13;
        baseSpinner = 16;
        baseMinH = 40;
        baseRadius = 14;
        break;
      case 'lg':
        baseH = 18;
        baseV = 16;
        baseFont = 16;
        baseSpinner = 20;
        baseMinH = 52;
        baseRadius = 18;
        break;
      case 'md':
      default:
        baseH = 16;
        baseV = 14;
        baseFont = 15;
        baseSpinner = 18;
        baseMinH = 48;
        baseRadius = 16;
    }

    // apply width scaling and light tablet boost
    final scale = isTablet
        ? widthScale * 1.06
        : widthScale; // on tablets slightly larger

    // final responsive values (respect user text scale)
    final font = (baseFont * scale * layoutTextScale).clamp(
      12.0,
      20.0,
    ); // keep readable
    final spinner = (baseSpinner * scale).clamp(14.0, 24.0); // spinner size
    final hPad = (baseH * scale).clamp(10.0, 24.0); // horizontal padding
    final vPad = (baseV * scale).clamp(8.0, 20.0); // vertical padding
    final minHeight = (baseMinH * scale).clamp(40.0, 58.0); // tap target
    final radius =
        borderRadius ?? (baseRadius * scale).clamp(12.0, 22.0); // corners

    // lighten padding for text variant (link-like)
    final EdgeInsets padding = (type == AppButtonType.text)
        ? EdgeInsets.symmetric(
            horizontal: hPad * 0.6,
            vertical: vPad * 0.7,
          ) // lighter feel
        : EdgeInsets.symmetric(horizontal: hPad, vertical: vPad); // normal

    return (
      padding: padding,
      font: font,
      spinner: spinner,
      minHeight: minHeight,
      radius: radius,
    );
  }

  // helper: map enum to string (small + tidy)
  String sizeEnumToString(AppButtonSize s) {
    switch (s) {
      case AppButtonSize.sm:
        return 'sm'; // small
      case AppButtonSize.lg:
        return 'lg'; // large
      case AppButtonSize.md:
      default:
        return 'md'; // medium
    }
  }

  // compute colors from theme + variant
  ({Color bg, Color fg, Color border, Color overlay}) _colors(
    BuildContext ctx,
  ) {
    final cs = Theme.of(ctx).colorScheme; // scheme from app theme
    switch (type) {
      case AppButtonType.primary: // solid primary
        return (
          bg: cs.primary,
          fg: cs.onPrimary,
          border: Colors.transparent,
          overlay: cs.onPrimary.withOpacity(.08),
        );
      case AppButtonType.secondary: // filled softer
        return (
          bg: cs.secondaryContainer,
          fg: cs.onSecondaryContainer,
          border: Colors.transparent,
          overlay: cs.onSecondaryContainer.withOpacity(.06),
        );
      case AppButtonType.outline: // transparent stroke
        return (
          bg: Colors.transparent,
          fg: cs.primary,
          border: cs.outlineVariant,
          overlay: cs.primary.withOpacity(.06),
        );
      case AppButtonType.text: // link-like
        return (
          bg: Colors.transparent,
          fg: cs.primary,
          border: Colors.transparent,
          overlay: cs.primary.withOpacity(.06),
        );
    }
  }

  // build inner content (spinner or label+icons)
  Widget _buildContent(
    BuildContext ctx,
    double font,
    double spinner,
    Color fg,
  ) {
    // busy → show progress
    if (isBusy) {
      return SizedBox(
        width: spinner, // spinner width
        height: spinner, // spinner height
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: fg,
        ), // thin spinner
      );
    }

    // merge provided text style with theme + responsive font
    final style = (textStyle ?? Theme.of(ctx).textTheme.titleMedium)?.copyWith(
      fontSize: font, // responsive font
      color: fg, // text color
      fontWeight: FontWeight.w600, // semi-bold
      letterSpacing: 0.2, // tiny tracking
    );

    // pieces row (leading, label, trailing)
    final List<Widget> pieces = [];

    if (leading != null) {
      pieces.add(
        Padding(
          padding: EdgeInsets.only(
            right: (font * 0.55).clamp(6, 10),
          ), // responsive gap
          child: IconTheme.merge(
            data: IconThemeData(color: fg, size: font + 1), // icon color/size
            child: leading!, // icon
          ),
        ),
      );
    }

    if (label != null) {
      pieces.add(
        Flexible(
          child: Text(
            label!, // the text
            maxLines: 1, // single line
            overflow: TextOverflow.ellipsis, // clip long text
            style: style, // style
          ),
        ),
      );
    }

    if (trailing != null) {
      pieces.add(
        Padding(
          padding: EdgeInsets.only(
            left: (font * 0.55).clamp(6, 10),
          ), // responsive gap
          child: IconTheme.merge(
            data: IconThemeData(color: fg, size: font + 1), // icon color/size
            child: trailing!, // icon
          ),
        ),
      );
    }

    // if no text nor icons, preserve height
    if (pieces.isEmpty) {
      final side = (font + 6).clamp(18, 28); // keep touch size
      return SizedBox(
        height: side.toDouble(),
        width: side.toDouble(),
      ); // minimal footprint
    }

    // centered row with tight main size
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: pieces,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme; // theme colors
    final m = _metrics(context); // responsive metrics
    final c = _colors(context); // variant colors

    // enabled = has onPressed and not busy
    final bool enabled = onPressed != null && !isBusy; // clickable

    // effective colors (disabled fallbacks)
    final Color bg = enabled
        ? c.bg
        : cs.surfaceVariant.withOpacity(.6); // background
    final Color fg = enabled
        ? c.fg
        : cs.onSurface.withOpacity(.38); // foreground
    final Color br = (type == AppButtonType.outline)
        ? c.border
        : Colors.transparent; // border

    // core material for ripple
    Widget core = Material(
      color: bg, // fill
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(m.radius), // responsive corners
        side: type == AppButtonType.outline
            ? BorderSide(color: br, width: 1)
            : BorderSide.none, // outline stroke
      ),
      child: InkWell(
        onTap: enabled ? onPressed : null, // tap
        borderRadius: BorderRadius.circular(m.radius), // ripple radius
        splashColor: c.overlay, // ripple
        highlightColor: c.overlay, // press
        focusNode: focusNode, // focus
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: m.minHeight), // min tap target
          child: Padding(
            padding: m.padding, // responsive padding
            child: Center(
              child: _buildContent(context, m.font, m.spinner, fg),
            ), // content
          ),
        ),
      ),
    );

    // semantics wrapper
    core = Semantics(
      button: true, // role
      enabled: enabled, // state
      label: semanticLabel ?? label, // a11y label
      child: core, // child
    );

    // expand full width if requested
    if (expand)
      core = SizedBox(width: double.infinity, child: core); // full width

    // add outer margin if provided
    if (margin != null)
      core = Padding(padding: margin!, child: core); // external spacing

    // final widget
    return core; // done
  }
}

// round icon-only button (responsive size)
class AppIconButton extends StatelessWidget {
  final VoidCallback? onPressed; // action (nullable)
  final Widget icon; // icon widget
  final String? tooltip; // tooltip text
  final bool isFilled; // filled or outline
  final double size; // diameter baseline
  final bool isBusy; // loading state

  const AppIconButton({
    super.key, // key
    required this.icon, // icon
    this.onPressed, // action
    this.tooltip, // optional tooltip
    this.isFilled = true, // default filled
    this.size = 44, // baseline diameter
    this.isBusy = false, // not loading by default
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context); // media
    final widthScale = (mq.size.width / 390).clamp(0.9, 1.2); // scale
    final diameter = (size * widthScale).clamp(40.0, 56.0); // responsive dia

    final cs = Theme.of(context).colorScheme; // colors
    final bool enabled = onPressed != null && !isBusy; // clickable
    final Color bg = isFilled ? cs.primary : Colors.transparent; // bg
    final Color fg = isFilled ? cs.onPrimary : cs.primary; // fg
    final Color br = isFilled
        ? Colors.transparent
        : cs.outlineVariant; // border

    final Widget content = isBusy
        ? SizedBox(
            width: (diameter * 0.45).clamp(18.0, 22.0), // spinner size
            height: (diameter * 0.45).clamp(18.0, 22.0), // spinner size
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: fg,
            ), // spinner
          )
        : IconTheme.merge(
            data: IconThemeData(
              color: fg,
              size: (diameter * 0.5).clamp(20.0, 26.0),
            ), // icon size
            child: icon, // icon
          );

    Widget btn = Material(
      color: enabled ? bg : cs.surfaceVariant.withOpacity(.6), // bg disabled
      shape: CircleBorder(side: BorderSide(color: br, width: 1)), // circle
      child: InkWell(
        onTap: enabled ? onPressed : null, // tap
        customBorder: const CircleBorder(), // ripple mask
        child: SizedBox(
          width: diameter, // responsive diameter
          height: diameter, // responsive diameter
          child: Center(child: content), // center inner
        ),
      ),
    );

    if (tooltip != null && tooltip!.isNotEmpty) {
      btn = Tooltip(message: tooltip!, child: btn); // optional tooltip
    }

    return btn; // done
  }
}
