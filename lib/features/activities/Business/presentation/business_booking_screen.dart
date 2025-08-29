import 'package:flutter/material.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';

class BusinessBookingScreen extends StatelessWidget {
  const BusinessBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [Text('bookings', style: tt.headlineSmall)],
      ),
    );
  }
}
