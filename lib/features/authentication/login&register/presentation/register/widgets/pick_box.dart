import 'package:flutter/material.dart'; // UI

class PickBox extends StatelessWidget {
  final String label; // button text
  final VoidCallback onPick; // tap handler

  const PickBox({super.key, required this.label, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme; // colors

    return InkWell(
      onTap: onPick, // open picker
      borderRadius: BorderRadius.circular(16), // ripple
      child: Container(
        height: 110, // height
        alignment: Alignment.center, // center
        decoration: BoxDecoration(
          color: cs.surfaceVariant.withOpacity(.35), // soft bg
          borderRadius: BorderRadius.circular(16), // radius
          border: Border.all(color: cs.outlineVariant), // border
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // center row
          children: [
            const Icon(Icons.image_outlined), // icon
            const SizedBox(width: 8), // gap
            Text(label), // label
          ],
        ),
      ),
    );
  }
}
