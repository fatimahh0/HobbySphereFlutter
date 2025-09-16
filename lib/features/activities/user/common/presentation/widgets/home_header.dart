// lib/features/activities/user/common/presentation/widgets/home_header.dart
import 'package:flutter/material.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:hobby_sphere/shared/widgets/notification_badge.dart';
import 'package:hobby_sphere/shared/theme/app_theme.dart';

class HomeHeader extends StatelessWidget {
  final String displayName;
  final String? subtitle;
  final String? avatarUrl; // can be absolute or like "/uploads/.."
  final String? imageBaseUrl; // e.g. "http://3.96.140.126:8080"
  final int unreadCount;
  final VoidCallback? onBellTap;

  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool dense; // smaller avatar/text
  final bool elevated; // shadow on/off

  const HomeHeader({
    super.key,
    required this.displayName,
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

  String? _absolute(String? u) {
    if (u == null || u.trim().isEmpty) return null;
    final url = u.trim();
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    if (url.startsWith('/') &&
        imageBaseUrl != null &&
        imageBaseUrl!.isNotEmpty) {
      return '${imageBaseUrl!.replaceFirst(RegExp(r'/$'), '')}$url';
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final text = theme.textTheme;
    final t = AppLocalizations.of(context)!;

    final resolvedAvatar = _absolute(avatarUrl);
    final avatarRadius = dense ? 18.0 : 22.0;

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
          CircleAvatar(
            radius: avatarRadius,
            backgroundColor: cs.surfaceVariant,
            backgroundImage:
                (resolvedAvatar != null && resolvedAvatar.isNotEmpty)
                ? NetworkImage(resolvedAvatar)
                : null,
            child: (resolvedAvatar == null || resolvedAvatar.isEmpty)
                ? Icon(
                    Icons.person,
                    color: cs.onSurfaceVariant,
                    size: dense ? 18 : 22,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: (dense ? text.titleSmall : text.titleMedium)?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle ?? t.homeFindActivity,
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
            onTap: onBellTap,
            iconSize: dense ? 22 : 26,
            tooltip: t.notifications,
          ),
        ],
      ),
    );
  }
}
