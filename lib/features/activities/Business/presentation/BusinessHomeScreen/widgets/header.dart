// ===== Flutter 3.35.x =====
// Simple header row with a title (L10n).
import 'package:flutter/material.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart' show AppLocalizations;

class HeaderWithBadge extends StatelessWidget {
  const HeaderWithBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final t = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            t.businessYourActivities,
            style: text.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox.shrink(),
        ],
      ),
    );
  }
}
