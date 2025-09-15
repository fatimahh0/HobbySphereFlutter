// activity_card.dart
// Flutter 3.35.x
// ActivityCard — responsive (no overflow) + absolute image URLs + debug logs

import 'package:flutter/foundation.dart'; // kDebugMode, debugPrint
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hobby_sphere/shared/theme/app_theme.dart'; // AppColors.muted

class ActivityCardData {
  final int id;
  final String title;
  final DateTime? start;
  final num? price;

  /// May be absolute ("http://.../img.jpg") or relative ("/uploads/xyz.jpg").
  final String? imageUrl;
  final String? location;

  const ActivityCardData({
    required this.id,
    required this.title,
    this.start,
    this.price,
    this.imageUrl,
    this.location,
  });
}

enum ActivityCardVariant { square, horizontal, compact }

class ActivityCard extends StatelessWidget {
  final ActivityCardData item;
  final ActivityCardVariant variant;
  final VoidCallback? onPressed;
  final String? currencyCode;

  /// Set this to your server host so relative paths become absolute.
  /// Example: "http://3.96.140.126:8080"
  final String? imageBaseUrl;

  // layout options
  final bool isSingle;
  final double? width;
  final EdgeInsets margin;
  final EdgeInsets padding;

  const ActivityCard({
    super.key,
    required this.item,
    this.variant = ActivityCardVariant.square,
    this.onPressed,
    this.currencyCode,
    this.imageBaseUrl,
    this.isSingle = false,
    this.width,
    this.margin = const EdgeInsets.only(bottom: 12),
    this.padding = const EdgeInsets.all(12),
  });

  // ---------------- helpers ----------------

  String _symbolFor(String? code) {
    switch ((code ?? '').trim().toUpperCase()) {
      case 'USD':
        return r'$';
      case 'EUR':
        return '€';
      case 'CAD':
        return 'C\$';
      case 'LBP':
      case 'L.L':
        return 'ل.ل';
      default:
        return (code ?? '').toUpperCase();
    }
  }

  String _formatPrice(num? p, String? code) {
    if (p == null) return '';
    final v = p % 1 == 0 ? p.toInt().toString() : p.toStringAsFixed(2);
    final s = _symbolFor(code);
    return s.isEmpty ? v : '$s$v';
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    return '${DateFormat('EEE, d MMM').format(dt)} · ${DateFormat('HH:mm').format(dt)}';
  }

  /// Turn a possibly-relative [u] into an absolute URL using [imageBaseUrl].
  /// Also prints what it resolved to (debug builds only).
  String? _absolute(String? u) {
    if (u == null) return null;
    var url = u.trim();
    if (url.isEmpty) return null;

    // Already absolute?
    if (url.startsWith('http://') || url.startsWith('https://')) {
      if (kDebugMode) debugPrint('[IMG] raw="$u" (already absolute)');
      return Uri.parse(url).toString();
    }

    // Normalize slashes in relative path
    url = url.replaceAll('\\', '/');
    final base = (imageBaseUrl ?? '').trim();

    if (base.isEmpty) {
      if (kDebugMode) {
        debugPrint(
          '[IMG] raw="$u" but imageBaseUrl is empty -> cannot resolve',
        );
      }
      return null;
    }

    // Remove trailing slash from base, ensure path starts with one
    final cleanBase = base.endsWith('/')
        ? base.substring(0, base.length - 1)
        : base;
    final cleanPath = url.startsWith('/') ? url : '/$url';

    final resolved = Uri.parse('$cleanBase$cleanPath').toString();
    if (kDebugMode) {
      debugPrint('[IMG] raw="$u" base="$imageBaseUrl" -> resolved="$resolved"');
    }
    return resolved;
  }

  Widget _imageBox({
    required String? url,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    final resolved = _absolute(url);

    if (resolved == null) {
      if (kDebugMode) debugPrint('[IMG] resolved=null (showing placeholder)');
      return Container(
        width: width,
        height: height,
        color: Colors.black12,
        alignment: Alignment.center,
        child: const Icon(Icons.image_not_supported_outlined),
      );
    }

    return Image.network(
      resolved,
      width: width,
      height: height,
      fit: fit,
      filterQuality: FilterQuality.medium,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) {
        if (kDebugMode) debugPrint('[IMG] FAILED to load: $resolved');
        return Container(
          width: width,
          height: height,
          color: Colors.black12,
          alignment: Alignment.center,
          child: const Icon(Icons.image_not_supported_outlined),
        );
      },
      loadingBuilder: (ctx, child, progress) {
        if (progress == null) return child;
        // Uncomment if you want spammy per-frame logs:
        // if (kDebugMode) debugPrint('[IMG] loading: $resolved');
        return Container(
          width: width,
          height: height,
          color: Colors.black12,
          alignment: Alignment.center,
          child: const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }

  Widget _info(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          item.title.isEmpty ? '—' : item.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        if (item.start != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 12,
                color: AppColors.muted,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  _formatDate(item.start),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.bodyMedium?.copyWith(
                    fontSize: 12,
                    color: AppColors.muted,
                  ),
                ),
              ),
            ],
          ),
        if (item.price != null) ...[
          const SizedBox(height: 6),
          Text(
            _formatPrice(item.price, currencyCode),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ],
    );
  }

  // ---------------- build ----------------

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(16);
    void tap() => onPressed?.call();

    switch (variant) {
      case ActivityCardVariant.compact:
        // Used inside a 2-col grid; compute an image height that fits without overflow.
        return Container(
          margin: margin,
          width: width,
          child: Material(
            color: cs.surface,
            borderRadius: radius,
            elevation: 2,
            child: InkWell(
              onTap: tap,
              borderRadius: radius,
              child: Padding(
                padding: padding,
                child: LayoutBuilder(
                  builder: (ctx, con) {
                    final hasFiniteHeight = con.maxHeight.isFinite;
                    final textScale = MediaQuery.textScaleFactorOf(ctx);
                    // space needed for title/date/price
                    final minText = 64.0 + (textScale - 1.0) * 22.0;
                    final imgH = hasFiniteHeight
                        ? (con.maxHeight - minText - 8).clamp(92.0, 160.0)
                        : 120.0;

                    final image = ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _imageBox(
                        url: item.imageUrl,
                        width: double.infinity,
                        height: imgH,
                      ),
                    );

                    if (hasFiniteHeight) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: imgH, child: image),
                          const SizedBox(height: 8),
                          Expanded(child: _info(context)),
                        ],
                      );
                    }
                    // fallback when parent is unconstrained
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AspectRatio(
                            aspectRatio: 16 / 10,
                            child: _imageBox(url: item.imageUrl),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _info(context),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );

      case ActivityCardVariant.horizontal:
        return Container(
          margin: margin,
          width: width,
          child: Material(
            color: cs.surface,
            borderRadius: radius,
            elevation: 3,
            child: InkWell(
              onTap: tap,
              borderRadius: radius,
              child: Padding(
                padding: padding,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 72,
                        height: 72,
                        child: _imageBox(url: item.imageUrl),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: _info(context)),
                  ],
                ),
              ),
            ),
          ),
        );

      case ActivityCardVariant.square:
        return Container(
          margin: margin,
          width: width ?? (isSingle ? 220 : null),
          child: AspectRatio(
            aspectRatio: 1,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: tap,
                borderRadius: radius,
                child: ClipRRect(
                  borderRadius: radius,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _imageBox(url: item.imageUrl),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: cs.surface,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.12),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: _info(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
    }
  }
}
