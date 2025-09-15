import 'package:flutter/material.dart'; // UI
import 'package:hobby_sphere/shared/widgets/app_text_field.dart'; // your field

class PillField extends StatelessWidget {
  final TextEditingController controller; // ctrl
  final String label; // label/hint
  final String? helper; // helper
  final ValueChanged<String>? onChanged; // cb

  const PillField({
    super.key,
    required this.controller,
    required this.label,
    this.helper,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller, // ctrl
      label: label, // label
      hint: label, // hint
      maxLines: 1, // one line
      borderRadius: 28, // pill
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      onChanged: onChanged, // cb
      helper: helper, // helper text
      filled: false, // clear bg
    );
  }
}
