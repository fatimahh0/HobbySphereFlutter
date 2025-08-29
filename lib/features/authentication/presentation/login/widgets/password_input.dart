import 'package:flutter/material.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:hobby_sphere/shared/widgets/app_text_field.dart';

class PasswordInput extends StatelessWidget {
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggleObscure;

  const PasswordInput({
    super.key,
    required this.controller,
    required this.obscure,
    required this.onToggleObscure,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return AppTextField(
      controller: controller,
      label: t.loginPassword,
      hint: '.........',
      prefix: const Icon(Icons.lock_outline),
      suffix: IconButton(
        icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
        onPressed: onToggleObscure,
      ),
      obscure: obscure,
      textInputAction: TextInputAction.done,
      borderRadius: 22,
      validator: (v) =>
          (v == null || v.length < 6) ? t.registerErrorLength : null,
    );
  }
}
