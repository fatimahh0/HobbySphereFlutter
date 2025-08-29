import 'package:flutter/material.dart';

import 'package:hobby_sphere/l10n/app_localizations.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            CircleAvatar(radius: 28, backgroundColor: cs.primary),
            const SizedBox(width: 12),
           
          ],
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          color: cs.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [Text('profile details', style: tt.headlineSmall)],
          ),
        ),
      ],
    );
  }
}
