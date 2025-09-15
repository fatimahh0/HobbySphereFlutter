import 'package:flutter/material.dart';

import 'package:hobby_sphere/l10n/app_localizations.dart';

class UserExploreScreen extends StatelessWidget {
  const UserExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(16), // page padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, // full width
        children: [Text('explore', style: tt.headlineSmall)],
      ),
    );
  }
}
