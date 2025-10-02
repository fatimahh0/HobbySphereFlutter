import 'package:flutter/foundation.dart'; // kDebugMode + debugPrint
import 'package:flutter/material.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:hobby_sphere/shared/theme/app_colors.dart';
import 'package:hobby_sphere/shared/widgets/notification_badge.dart';
import 'package:hobby_sphere/shared/theme/app_theme.dart';

class HomeHeader extends StatelessWidget {
  final String? firstName;
  final String? lastName;

  final String? subtitle;
  final String? avatarUrl; // can be absolute or relative
  final String? imageBaseUrl; // e.g. "http://3.96.140.126:8080"
  final int unreadCount;
  final VoidCallback? onBellTap;

  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool dense;
  final bool elevated;

  const HomeHeader({
    super.key,
    this.firstName,
    this.lastName,
    this.subtitle,
    this.avatarUrl,
    this.imageBaseUrl,
    this.unreadCount = 0,
    this.onBellTap,
    this.margin = const EdgeInsets.fromLTRB(16, 12, 16, 8),
    this.padding = const EdgeInsets.all(12),
    this.radius = 16,
    this.dense = false,
    this.elevated = true,
  });

  // Join base + path safely (no double slashes).
  String _joinBase(String base, String path) {
    final b = base.replaceFirst(RegExp(r'/*$'), ''); // trim trailing /
    final p = path.replaceFirst(RegExp(r'^/*'), ''); // trim leading /
    return '$b/$p';
  }

  // Build absolute URL for avatar.
  String? _absolute(String? u) {
    if (u == null) return null;
    final url = u.trim();
    if (url.isEmpty) return null;

    // Already absolute
    if (url.startsWith('http://') || url.startsWith('https://')) return url;

    // Protocol-relative (rare): //domain/path -> assume https
    if (url.startsWith('//')) return 'https:$url';

    // Relative with leading slash: "/uploads/a.jpg"
    if (url.startsWith('/')) {
      if (imageBaseUrl == null || imageBaseUrl!.isEmpty) return null;
      return _joinBase(imageBaseUrl!, url);
    }

    // Relative without slash: "uploads/a.jpg"
    if (imageBaseUrl != null && imageBaseUrl!.isNotEmpty) {
      return _joinBase(imageBaseUrl!, '/$url');
    }

    // As a last resort, return as-is (may still fail)
    return url;
  }

  String _fullNameOrGuest() {
    final fn = (firstName ?? '').trim();
    final ln = (lastName ?? '').trim();
    final full = [fn, ln].where((s) => s.isNotEmpty).join(' ').trim();
    return full.isNotEmpty ? full : 'Guest';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final text = theme.textTheme;
    final t = AppLocalizations.of(context)!;

    final resolved = _absolute(avatarUrl); // final URL to try
    final avatarRadius = dense ? 18.0 : 22.0;

    if (kDebugMode) {
      debugPrint(
        '[HomeHeader] first="$firstName" last="$lastName" '
        'avatarUrl="$avatarUrl" imageBaseUrl="$imageBaseUrl" '
        'resolved="$resolved"',
      );
    }

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : const [],
      ),
      child: Row(
        children: [
          // Use ClipOval + Image.network for graceful error handling.
          // HomeHeader.dart  — avatar resolver mirrors UserProfileHeader
          ClipOval(
            child: SizedBox(
              width: avatarRadius * 2,
              height: avatarRadius * 2,
              child: (() {
                final raw = (avatarUrl ?? '').trim();
                if (raw.isEmpty) {
                  return _AvatarFallbackIcon(
                    size: dense ? 18 : 22,
                    color: cs.onSurfaceVariant,
                  );
                }

                // If absolute (http/https), use as-is. Otherwise prefix with imageBaseUrl.
                final isAbsolute =
                    raw.startsWith('http://') || raw.startsWith('https://');
                final base = (imageBaseUrl ?? '').replaceFirst(
                  RegExp(r'/+$'),
                  '',
                );
                final path = raw.startsWith('/') ? raw : '/$raw';
                final resolved = isAbsolute ? raw : '$base$path';

                return Image.network(
                  resolved,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _AvatarFallbackIcon(
                    size: dense ? 18 : 22,
                    color: cs.onSurfaceVariant,
                  ),
                  loadingBuilder: (ctx, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: cs.surfaceVariant,
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: dense ? 14 : 16,
                        height: dense ? 14 : 16,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                );
              })(),
            ),
          ),

          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _fullNameOrGuest(), // full name
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: (dense ? text.titleSmall : text.titleMedium)?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle ?? t.homeFindActivity, // sub line
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: (dense ? text.bodySmall : text.bodyMedium)?.copyWith(
                    fontSize: dense ? 12 : 13,
                    color: AppColors.muted,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          NotificationBadge(
            count: unreadCount,
            onTap: () {
              if (kDebugMode) debugPrint('[HomeHeader] Bell tapped');
              onBellTap?.call();
            },
            iconSize: dense ? 22 : 26,
            tooltip: t.notifications,
          ),
        ],
      ),
    );
  }
}

// Small fallback icon widget for avatar.
class _AvatarFallbackIcon extends StatelessWidget {
  final double size;
  final Color color;
  const _AvatarFallbackIcon({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant,
      alignment: Alignment.center,
      child: Icon(Icons.person, size: size, color: color),
    );
  }
}
