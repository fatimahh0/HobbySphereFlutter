import 'package:flutter/material.dart'; // UI

import 'package:hobby_sphere/l10n/app_localizations.dart'; // i18n

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key}); // ctor

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!; // i18n
    final cs = Theme.of(context).colorScheme; // colors
    final tt = Theme.of(context).textTheme; // typography

    return Container(
      color: cs.surface, // background from theme
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, // compact center
          children: [Text('home', style: tt.headlineSmall)],
        ),
      ),
    );
  }
}
