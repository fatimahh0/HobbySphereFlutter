import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ToastType { success, error, info }

// prevent stacked toasts
OverlayEntry? _currentToastEntry;
Timer? _currentToastTimer;

/// Themed + RTL-safe top toast
void showTopToast(
  BuildContext context,
  String message, {
  ToastType type = ToastType.info,
  Duration duration = const Duration(milliseconds: 1800),
  bool haptics = false,
}) {
  final overlay = Overlay.of(context);
  if (overlay == null || message.trim().isEmpty) return;

  // remove previous toast if any
  _currentToastTimer?.cancel();
  _currentToastEntry?.remove();
  _currentToastEntry = null;

  final scheme = Theme.of(context).colorScheme;
  final isDark = scheme.brightness == Brightness.dark;
  final textDir = Directionality.of(context);
  final topInset = MediaQuery.of(context).padding.top + 12;

  // pick colors/icons by type from theme
  Color bg, fg;
  IconData icon;
  switch (type) {
    case ToastType.success:
      bg = scheme.primary;
      fg = scheme.onPrimary;
      icon = Icons.check_circle_rounded;
      break;
    case ToastType.error:
      bg = scheme.error;
      fg = scheme.onError;
      icon = Icons.error_rounded;
      break;
    case ToastType.info:
    default:
      bg = isDark ? scheme.surfaceVariant : scheme.secondary;
      fg = isDark ? scheme.onSurfaceVariant : scheme.onSecondary;
      icon = Icons.info_rounded;
      break;
  }

  if (haptics) {
    type == ToastType.error
        ? HapticFeedback.heavyImpact()
        : HapticFeedback.selectionClick();
  }

  final entry = OverlayEntry(
    builder: (_) => Directionality(
      textDirection: textDir,
      child: _TopToastSurface(
        message: message,
        bg: bg,
        fg: fg,
        icon: icon,
        topInset: topInset,
      ),
    ),
  );

  overlay.insert(entry);
  _currentToastEntry = entry;

  _currentToastTimer = Timer(duration, () {
    _currentToastEntry?.remove();
    _currentToastEntry = null;
  });
}

class _TopToastSurface extends StatefulWidget {
  final String message;
  final Color bg;
  final Color fg;
  final IconData icon;
  final double topInset;

  const _TopToastSurface({
    required this.message,
    required this.bg,
    required this.fg,
    required this.icon,
    required this.topInset,
  });

  @override
  State<_TopToastSurface> createState() => _TopToastSurfaceState();
}

class _TopToastSurfaceState extends State<_TopToastSurface>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 230),
  )..forward();

  late final Animation<Offset> _slide = Tween(
    begin: const Offset(0, -0.25),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));

  late final Animation<double> _fade = CurvedAnimation(
    parent: _c,
    curve: Curves.easeOut,
  );

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(top: widget.topInset),
            child: SlideTransition(
              position: _slide,
              child: FadeTransition(
                opacity: _fade,
                child: Material(
                  color: Colors.transparent,
                  child: Semantics(
                    liveRegion: true,
                    label: widget.message,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 520),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: widget.bg,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 16,
                            spreadRadius: -4,
                            offset: Offset(0, 8),
                            color: Colors.black26,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(widget.icon, color: widget.fg, size: 18),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              widget.message,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                color: widget.fg,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
