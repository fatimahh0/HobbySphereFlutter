// lib/shared/widgets/branding.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hobby_sphere/core/network/globals.dart' as g;

/// Compact brand widget you can use in AppBars, headers, etc.
/// - Hides itself when no logo & [hideIfEmpty] = true (default)
/// - Can hide the text with [showName] = false
/// - Optional circular or rounded-rect logo
class BrandingTitle extends StatelessWidget {
  final double size;
  final bool showName; // show "appName" text next to the icon
  final bool circularLogo; // circle vs rounded rectangle
  final double radius; // corner radius when not circular
  final bool hideIfEmpty; // hide entire widget if logo url empty
  final TextStyle? textStyle;
  final double spacing;

  const BrandingTitle({
    super.key,
    this.size = 22,
    this.showName = true,
    this.circularLogo = false,
    this.radius = 6,
    this.hideIfEmpty = true,
    this.textStyle,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    final hasUrl = g.appLogoUrl.isNotEmpty;

    // If no logo and you want it hidden, render nothing.
    if (!hasUrl && hideIfEmpty) {
      // Optionally still show the name if you want (flip logic if needed)
      return showName
          ? Text(g.appName, style: _style(context))
          : const SizedBox.shrink();
    }

    final logo = hasUrl
        ? _NetLogo(
            url: g.appLogoUrl,
            size: size,
            circular: circularLogo,
            radius: radius,
          )
        : const SizedBox.shrink(); // nothing if no url and hideIfEmpty=true

    final name = showName
        ? Flexible(
            child: Text(
              g.appName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _style(context),
            ),
          )
        : const SizedBox.shrink();

    // If only name (no logo), return text directly so no extra padding.
    if (!hasUrl && showName) return name;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        logo,
        if (showName) SizedBox(width: spacing),
        if (showName) name,
      ],
    );
  }

  TextStyle _style(BuildContext context) =>
      textStyle ?? Theme.of(context).textTheme.titleMedium!;
}

/// Network logo with graceful loading/error states.
/// If HTTP (not HTTPS) on Android 9+, make sure you set android:usesCleartextTraffic="true".
class _NetLogo extends StatelessWidget {
  final String url;
  final double size;
  final bool circular;
  final double radius;

  const _NetLogo({
    required this.url,
    required this.size,
    required this.circular,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    // Create non-nullable border radius only when used (non-circular case)
    Widget image = Image.network(
      url,
      width: size,
      height: size,
      fit: BoxFit.cover,
      // tiny loading shimmer-ish placeholder
      loadingBuilder: (context, child, evt) {
        if (evt == null) return child;
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(.5),
            shape: circular ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: circular ? null : BorderRadius.circular(radius),
          ),
        );
      },
      // on error → hide (keeps the whole widget invisible if hideIfEmpty=true)
      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      // enable downscaling cache for sharper small icons
      cacheWidth: kIsWeb
          ? null
          : (size * MediaQuery.devicePixelRatioOf(context)).round(),
      cacheHeight: kIsWeb
          ? null
          : (size * MediaQuery.devicePixelRatioOf(context)).round(),
    );

    if (circular) {
      return ClipOval(child: image);
    } else {
      final borderRadius = BorderRadius.circular(radius);
      return ClipRRect(borderRadius: borderRadius, child: image);
    }
  }
}
