// ===== Flutter 3.35.x =====
// PrivacyPolicyScreen — localized privacy policy text

import 'package:flutter/material.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!; // i18n
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr.privacyTitle),
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: theme.colorScheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              tr.privacyTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Paragraphs
            Text(
              tr.privacyP1,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 12),
            Text(
              tr.privacyP2,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 12),
            Text(
              tr.privacyP3,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 12),
            Text(
              tr.privacyP4,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 12),
            Text(
              tr.privacyP5,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),

            const SizedBox(height: 24),

            // Last updated footer
            Text(
              tr.privacyUpdated,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
