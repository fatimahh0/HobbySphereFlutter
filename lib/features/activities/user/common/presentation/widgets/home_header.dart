import 'package:flutter/material.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:hobby_sphere/shared/widgets/notification_badge.dart';
import 'package:hobby_sphere/shared/theme/app_theme.dart';

class HomeHeader extends StatelessWidget {
  final String displayName;
  final String? subtitle;
  final String? avatarUrl;
  final int unreadCount;
  final VoidCallback? onBellTap;

  // NEW: control outer margin/radius if you want edge-to-edge
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final double radius;

  const HomeHeader({
    super.key,
    required this.displayName,
    this.subtitle,
    this.avatarUrl,
    this.unreadCount = 0,
    this.onBellTap,
    this.margin = const EdgeInsets.fromLTRB(16, 12, 16, 8),
    this.padding = const EdgeInsets.all(12),
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final text = theme.textTheme;
    final t = AppLocalizations.of(context)!;

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: cs.surfaceVariant,
            backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                ? NetworkImage(avatarUrl!)
                : null,
            child: (avatarUrl == null || avatarUrl!.isEmpty)
                ? Icon(Icons.person, color: cs.onSurfaceVariant)
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
                  style: text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle ?? t.homeFindActivity,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodyMedium?.copyWith(
                    fontSize: 13,
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
            iconSize: 26,
            tooltip: t.notifications,
          ),
        ],
      ),
    );
  }
}
