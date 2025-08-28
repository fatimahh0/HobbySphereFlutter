// Flutter 3.35.x
import 'package:flutter/material.dart'; // UI
import 'package:hobby_sphere/l10n/app_localizations.dart'
    show AppLocalizations; // L10n
import 'package:hobby_sphere/ui/widgets/business_notification_badge.dart'; // badge button

class WelcomeSection extends StatelessWidget {
  // open notifications screen
  final VoidCallback? onOpenNotifications; // nav hook
  // open create activity screen
  final VoidCallback? onOpenCreateActivity; // nav hook
  // token for badge (to fetch count)
  final String token; // auth token

  const WelcomeSection({
    super.key, // key
    this.onOpenNotifications, // hook
    this.onOpenCreateActivity, // hook
    required this.token, // token
  });

  @override
  Widget build(BuildContext context) {
    // theme + strings
    final scheme = Theme.of(context).colorScheme; // colors
    final t = AppLocalizations.of(context)!; // L10n
    final text = Theme.of(context).textTheme; // fonts

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16), // outer spacing
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // left align
        children: [
          // header row: title + notifications badge (tap opens notifications)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // left/right
            children: [
              // big title "Welcome!"
              Flexible(
                child: Text(
                  t.businessWelcome, // "Welcome to your dashboard!"
                  style: text.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold, // bold
                    color: scheme.primary, // primary color
                  ),
                ),
              ),
              // tappable badge
              IconButton(
                onPressed: onOpenNotifications, // open notifications
                icon: BusinessNotificationBadge(
                  token: token, // pass token so badge can load
                  iconSize: 26, // same size as RN
                ),
                tooltip: t.socialNotifications, // a11y text
              ),
            ],
          ),

          const SizedBox(height: 4), // small gap
          // subtitle "Manage your activities..."
          Text(
            t.businessManageText, // L10n subtitle
            style: text.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withOpacity(0.7), // muted
            ),
          ),

          const SizedBox(height: 12), // gap
          // CTA button "Create New Activity"
          SizedBox(
            width: 220, // nice width
            child: ElevatedButton.icon(
              onPressed: onOpenCreateActivity, // open create
              icon: const Icon(Icons.add_circle_outline), // add icon
              label: Text(t.businessCreateActivity), // L10n label
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.primary, // primary
                foregroundColor: scheme.onPrimary, // text/icon
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ), // padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ), // rounded
              ),
            ),
          ),
        ],
      ),
    );
  }
}
