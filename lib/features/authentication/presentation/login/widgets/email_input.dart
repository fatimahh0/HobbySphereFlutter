import 'package:flutter/material.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:hobby_sphere/shared/widgets/app_text_field.dart';

class EmailInput extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?) validator;
  final VoidCallback onSwapToPhone;

  const EmailInput({
    super.key,
    required this.controller,
    required this.validator,
    required this.onSwapToPhone,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        AppTextField(
          controller: controller,
          label: t.email,
          hint: t.loginEmail,
          prefix: const Icon(Icons.email_outlined),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          borderRadius: 22,
          filled: false,
          validator: validator,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: onSwapToPhone,
            child: Text(
              t.loginUsePhoneInstead,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: cs.primary, fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
