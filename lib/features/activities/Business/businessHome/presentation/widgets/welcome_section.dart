// ===== Flutter 3.35.x =====
// Welcome block: title, subtitle, notifications, and "Create Activity".
import 'package:flutter/material.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart' show AppLocalizations;
// If you have this badge widget, keep the import; otherwise replace with a plain Icon.
// import 'package:hobby_sphere/ui/widgets/business_notification_badge.dart';

class WelcomeSection extends StatelessWidget {
  final VoidCallback? onOpenNotifications;
  final VoidCallback? onOpenCreateActivity;
  final String token;

  const WelcomeSection({
    super.key,
    this.onOpenNotifications,
    this.onOpenCreateActivity,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final t = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  t.businessWelcome,
                  style: text.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.primary,
                  ),
                ),
              ),
              IconButton(
                onPressed: onOpenNotifications,
                // Replace with your badge widget if you have it:
                // icon: BusinessNotificationBadge(token: token, iconSize: 26),
                icon: const Icon(Icons.notifications_outlined, size: 26),
                tooltip: t.socialNotifications,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            t.businessManageText,
            style: text.bodyMedium?.copyWith(
              color: scheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 220,
            child: ElevatedButton.icon(
              onPressed: onOpenCreateActivity,
              
              icon: const Icon(Icons.add_circle_outline),
              label: Text(t.businessCreateActivity),
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                
              ),
            ),
          ),
        ],
      ),
    );
  }
}
