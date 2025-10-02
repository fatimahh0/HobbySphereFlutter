import 'package:flutter/material.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';

class RegisterFooter extends StatelessWidget {
  final VoidCallback onRegister;
  const RegisterFooter({super.key, required this.onRegister});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        Text('${t.loginNoAccount} ', style: text.bodyMedium),
        GestureDetector(
          onTap: onRegister,
          child: Text(
            t.loginRegister,
            style: text.bodyMedium?.copyWith(color: cs.primary, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
