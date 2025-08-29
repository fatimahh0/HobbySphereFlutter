import 'package:flutter/material.dart';

class ReopenButton extends StatelessWidget {
  const ReopenButton({super.key, required this.onReopen});
  final VoidCallback onReopen;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ElevatedButton.icon(
      onPressed: onReopen,
      icon: const Icon(Icons.refresh_outlined, size: 18),
      label: const Text('Reopen'),
      style: ElevatedButton.styleFrom(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
