import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';

class PhoneInput extends StatelessWidget {
  final String initialIso;
  final bool submittedOnce;
  final void Function(String e164, String national, String iso) onChanged;
  final VoidCallback onSwapToEmail;

  const PhoneInput({
    super.key,
    required this.initialIso,
    required this.onChanged,
    required this.onSwapToEmail,
    this.submittedOnce = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    String iso = initialIso;

    return Column(
      children: [
        Material(
          color: cs.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(color: cs.outlineVariant, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: IntlPhoneField(
              initialCountryCode: iso,
              autovalidateMode: AutovalidateMode.disabled,
              disableLengthCheck: true,
              decoration: const InputDecoration(hintText: '', border: InputBorder.none, counterText: ''),
              pickerDialogStyle: PickerDialogStyle(
                searchFieldInputDecoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: t.searchPlaceholder,
                ),
              ),
              invalidNumberMessage: t.loginPhoneInvalid,
              onChanged: (p) => onChanged(p.completeNumber, p.number, p.countryISOCode),
              onCountryChanged: (c) => iso = c.code,
              validator: (p) => (p == null || p.number.trim().isEmpty) ? t.loginErrorRequired : null,
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: onSwapToEmail,
            child: Text(
              t.loginUseEmailInstead,
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
