import 'package:flutter/material.dart';

import 'package:hobby_sphere/l10n/app_localizations.dart';

class UserTicketsScreen extends StatelessWidget {
  const UserTicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [Text('tickets', style: tt.headlineSmall)],
      ),
    );
  }
}
