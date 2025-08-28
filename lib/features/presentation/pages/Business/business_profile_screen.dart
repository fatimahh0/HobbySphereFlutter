import 'package:flutter/material.dart';

import 'package:hobby_sphere/l10n/app_localizations.dart';

class BusinessProfileScreen extends StatelessWidget {
  const BusinessProfileScreen({super.key});

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
            Column(
              children: [
                Text('business name', style: tt.titleMedium),
              ],
            ),
          ],
        ),
        
      ],
    );
  }
}
