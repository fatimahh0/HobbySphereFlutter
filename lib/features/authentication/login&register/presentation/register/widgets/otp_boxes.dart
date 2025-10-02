import 'package:flutter/material.dart'; // UI
import 'package:flutter/services.dart'; // digits only

// Row of 6 one-char boxes for OTP
class OtpBoxes extends StatelessWidget {
  final List<TextEditingController> ctrls; // 6 ctrls
  final List<FocusNode> nodes; // 6 nodes
  final ValueChanged<String> onChanged; // full code cb

  const OtpBoxes({
    super.key,
    required this.ctrls,
    required this.nodes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme; // colors

    return Row(
      mainAxisAlignment: MainAxisAlignment.center, // center row
      children: List.generate(6, (i) {
        return Container(
          width: 44, // box width
          height: 48, // box height
          margin: const EdgeInsets.symmetric(horizontal: 6), // spacing
          child: TextField(
            controller: ctrls[i], // this ctrl
            focusNode: nodes[i], // this node
            textAlign: TextAlign.center, // center text
            style: Theme.of(context).textTheme.titleMedium, // font
            maxLength: 1, // 1 char
            keyboardType: TextInputType.number, // numeric
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              counterText: '', // hide counter
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8), // radius
                borderSide: BorderSide(color: cs.primary), // border
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: cs.outlineVariant), // subtle
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: cs.primary, width: 1.6),
              ),
            ),
            onChanged: (v) {
              if (v.isNotEmpty && i < 5) nodes[i + 1].requestFocus(); // next
              if (v.isEmpty && i > 0) nodes[i - 1].requestFocus(); // prev
              onChanged(ctrls.map((c) => c.text).join()); // emit
            },
          ),
        );
      }),
    );
  }
}
