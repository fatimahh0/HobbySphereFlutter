import 'package:flutter/material.dart';

import 'package:hobby_sphere/l10n/app_localizations.dart';

class UserCommunityScreen extends StatelessWidget {
  const UserCommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Card(
        elevation: 0,
        color: cs.surfaceContainer, // soft card surface
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [Text('community', style: tt.headlineSmall)],
          ),
        ),
      ),
    );
  }
}
