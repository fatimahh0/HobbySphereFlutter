// lib/features/activities/user/common/presentation/widgets/activity_card.dart
// Flutter 3.35.x
// Smaller compact card: safe sizing, currency symbols, absolute image URLs.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hobby_sphere/shared/theme/app_theme.dart';
import 'package:hobby_sphere/shared/utils/currency_utils.dart';

class ActivityCardData {
  final int id;
  final String title;
  final DateTime? start;
  final num? price;

  /// Can be absolute ("http://.../img.jpg") or relative ("/uploads/xyz.jpg").
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

  /// Raw code from backend (e.g. "CAD", "EURO", "EUR", "USD", "LBP"...)
  final String? currencyCode;

  /// If backend returns relative paths, pass your server root
  /// e.g. "http://3.96.140.126:8080"
  final String? imageBaseUrl;

  // layout
  final bool isSingle;
  final double? width;
  final EdgeInsets margin;
  final EdgeInsets padding;

  const ActivityCard({
    super.key,
    required this.item,
    this.variant = ActivityCardVariant.compact,
    this.onPressed,
    this.currencyCode,
    this.imageBaseUrl,
    this.isSingle = false,
    this.width,
    this.margin = const EdgeInsets.only(bottom: 4), // smaller gap
    this.padding = const EdgeInsets.all(8), // smaller padding
  });

  // ---------- helpers ----------
  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    return '${DateFormat('EEE, d MMM').format(dt)} · ${DateFormat('HH:mm').format(dt)}';
  }

  /// Make possibly-relative URLs absolute using [imageBaseUrl].
  String? _absolute(String? u) {
    if (u == null) return null;
    var url = u.trim();
    if (url.isEmpty) return null;

    if (url.startsWith('http://') || url.startsWith('https://')) {
      return Uri.parse(url).toString();
    }
    url = url.replaceAll('\\', '/');

    final base = (imageBaseUrl ?? '').trim();
    if (base.isEmpty) {
      if (kDebugMode) debugPrint('[IMG] base empty → placeholder for "$u"');
      return null;
    }
    final cleanBase = base.endsWith('/')
        ? base.substring(0, base.length - 1)
        : base;
    final cleanPath = url.startsWith('/') ? url : '/$url';
    final resolved = Uri.parse('$cleanBase$cleanPath').toString();
    if (kDebugMode) debugPrint('[IMG] raw="$u" -> "$resolved"');
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
      return Container(
        width: width,
        height: height,
        color: Colors.black12,
        alignment: Alignment.center,
        child: const Icon(Icons.image_not_supported_outlined, size: 18),
      );
    }
    return Image.network(
      resolved,
      width: width,
      height: height,
      fit: fit,
      filterQuality: FilterQuality.medium,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => Container(
        width: width,
        height: height,
        color: Colors.black12,
        alignment: Alignment.center,
        child: const Icon(Icons.image_not_supported_outlined, size: 18),
      ),
      loadingBuilder: (ctx, child, progress) {
        if (progress == null) return child;
        return Container(
          width: width,
          height: height,
          color: Colors.black12,
          alignment: Alignment.center,
          child: const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }

  Widget _info(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    // smaller text sizes to fit tiny tiles
    final titleStyle = tt.bodyMedium?.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: 12,
      height: 1.15,
    );
    final subStyle = tt.bodyMedium?.copyWith(
      fontSize: 10,
      color: AppColors.muted,
      height: 1.15,
    );
    final priceStyle = tt.bodyMedium?.copyWith(
      fontWeight: FontWeight.w700,
      fontSize: 12,
      height: 1.15,
    );

    final dateText = _formatDate(item.start);
    final priceText = formatPrice(item.price, currencyCode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          item.title.isEmpty ? '—' : item.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
          style: titleStyle,
        ),
        if (dateText.isNotEmpty) ...[
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 11,
                color: AppColors.muted,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  dateText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: subStyle,
                ),
              ),
            ],
          ),
        ],
        if (priceText.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            priceText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: priceStyle,
          ),
        ],
      ],
    );
  }

  // ---------- build ----------
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(12); // smaller radius
    void tap() => onPressed?.call();

    switch (variant) {
      case ActivityCardVariant.compact:
        // Optimized for 2-col grids with fixed mainAxisExtent.
        return Container(
          margin: margin,
          width: width,
          child: Material(
            color: cs.surface,
            borderRadius: radius,
            clipBehavior: Clip.antiAlias,
            elevation: 1, // a bit flatter
            child: InkWell(
              onTap: tap,
              borderRadius: radius,
              child: Padding(
                padding: padding,
                child: LayoutBuilder(
                  builder: (ctx, con) {
                    final tileH = con.maxHeight.isFinite
                        ? con.maxHeight
                        : 168.0;
                    // Smaller image so text always fits:
                    // ~44–50% of tile height (tighter clamp).
                    final imgH = (tileH * 0.46).clamp(72.0, 118.0);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: _imageBox(
                            url: item.imageUrl,
                            width: double.infinity,
                            height: imgH,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Flexible(fit: FlexFit.loose, child: _info(context)),
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
            clipBehavior: Clip.antiAlias,
            elevation: 2,
            child: InkWell(
              onTap: tap,
              borderRadius: radius,
              child: Padding(
                padding: padding,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: _imageBox(url: item.imageUrl),
                      ),
                    ),
                    const SizedBox(width: 8),
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
          width: width ?? (isSingle ? 200 : null), // narrower single width
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
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: cs.surface,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.10),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
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
