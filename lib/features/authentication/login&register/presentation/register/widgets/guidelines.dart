import 'package:flutter/material.dart'; // UI base
import 'package:hobby_sphere/l10n/app_localizations.dart'; // l10n

// Password tips list (two rules from your keys)
class Guidelines extends StatelessWidget {
  const Guidelines({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!; // l10n ref
    final style = Theme.of(context).textTheme.bodyMedium; // text style

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // left align
      children: [
        Text(t.emailRegistrationRule1, style: style), // • 8 chars
        Text(t.emailRegistrationRule2, style: style), // • 1 letter/num/special
      ],
    );
  }
}
