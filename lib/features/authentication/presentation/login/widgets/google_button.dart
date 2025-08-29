import 'package:flutter/material.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:hobby_sphere/shared/widgets/app_button.dart';

class GoogleButton extends StatelessWidget {
  final VoidCallback onPressed;
  const GoogleButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return AppButton(
      onPressed: onPressed,
      type: AppButtonType.outline,
      size: AppButtonSize.md,
      expand: true,
      leading: Image.asset(
        'assets/icons/google.png',
        width: 22, height: 22,
        errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata),
      ),
      label: t.loginGoogleSignIn,
      borderRadius: 22,
    );
  }
}
