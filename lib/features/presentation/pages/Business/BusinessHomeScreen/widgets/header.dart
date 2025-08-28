// Flutter 3.35.x
import 'package:flutter/material.dart'; // UI
import 'package:hobby_sphere/l10n/app_localizations.dart'
    show AppLocalizations; // L10n

class HeaderWithBadge extends StatelessWidget {
  const HeaderWithBadge({super.key}); // simple stateless

  @override
  Widget build(BuildContext context) {
    // theme + strings
    final scheme = Theme.of(context).colorScheme; // colors
    final t = AppLocalizations.of(context)!; // L10n
    final text = Theme.of(context).textTheme; // fonts

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8), // spacing
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // layout like RN
        children: [
          // left title "Your Activities"
          Text(
            t.businessYourActivities, // L10n
            style: text.titleLarge?.copyWith(
              fontWeight: FontWeight.w600, // semi-bold
              color: scheme.onSurface, // text color
            ),
          ),
          // right side intentionally empty (RN file had no content here)
          const SizedBox.shrink(), // placeholder
        ],
      ),
    );
  }
}
