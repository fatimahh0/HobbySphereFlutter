import 'package:flutter/material.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';


class BusinessActivitiesScreen extends StatelessWidget {
  const BusinessActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('activities', style: tt.headlineSmall),
         
         
        ],
      ),
    );
  }
}
