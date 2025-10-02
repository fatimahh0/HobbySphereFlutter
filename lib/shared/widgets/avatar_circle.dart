import 'package:flutter/material.dart';
import 'package:hobby_sphere/shared/utils/image_url.dart';

/// Circular avatar that accepts a raw image URL (absolute or relative).
/// - Converts the URL to absolute using absoluteImageUrl()
/// - Shows a fallback icon if URL is missing or fails to load
class AvatarCircle extends StatelessWidget {
  final String? imageUrl; // raw URL from backend
  final double size; // diameter of avatar
  final IconData fallbackIcon; // shown on error/empty
  final double? iconSize; // optional custom fallback icon size
  final Color? borderColor;

  const AvatarCircle({
    super.key,
    required this.imageUrl,
    this.size = 40,
    this.fallbackIcon = Icons.person,
    this.iconSize,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final resolved = absoluteImageUrl(imageUrl);
    final cs = Theme.of(context).colorScheme;
    final fallback = Icon(
      fallbackIcon,
      size: iconSize ?? size * 0.45,
      color: cs.onSurfaceVariant,
    );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: cs.surface,
        border: Border.all(color: borderColor ?? cs.outlineVariant, width: 1),
      ),
      child: ClipOval(
        child: resolved == null
            ? Center(child: fallback)
            : Image.network(
                resolved,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(child: fallback),
                loadingBuilder: (ctx, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: cs.surfaceVariant,
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: (iconSize ?? size * 0.45) * 0.6,
                      height: (iconSize ?? size * 0.45) * 0.6,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
