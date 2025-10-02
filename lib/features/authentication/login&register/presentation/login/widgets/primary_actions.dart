import 'package:flutter/material.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:hobby_sphere/shared/widgets/app_button.dart';

class PrimaryActions extends StatelessWidget {
  final VoidCallback onLogin;
  final VoidCallback onForgot;

  const PrimaryActions({
    super.key,
    required this.onLogin,
    required this.onForgot,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      children: [
        AppButton(
          onPressed: onLogin,
          type: AppButtonType.primary,
          size: AppButtonSize.lg,
          expand: true,
          label: t.loginLogin,
        ),
        TextButton(
          onPressed: onForgot,
          child: Text(
            t.loginForgetPassword,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(.8),
            ),
          ),
        ),
      ],
    );
  }
}
