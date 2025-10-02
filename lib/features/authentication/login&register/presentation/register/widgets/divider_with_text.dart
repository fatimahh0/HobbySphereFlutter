import 'package:flutter/material.dart'; // UI

class DividerWithText extends StatelessWidget {
  final String text; // middle label
  const DividerWithText({super.key, required this.text}); // ✅ const ctor

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme; // text theme
    final cs = Theme.of(context).colorScheme; // colors
    return Row(
      children: [
        Expanded(child: Divider(color: cs.outlineVariant)), // left line
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8), // gap
          child: Text(text, style: tt.bodyMedium), // label
        ),
        Expanded(child: Divider(color: cs.outlineVariant)), // right line
      ],
    );
  }
}
