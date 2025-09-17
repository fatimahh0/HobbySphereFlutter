// Stepper control for participants                                   // file role
import 'package:flutter/material.dart'; // ui

class ParticipantsStepper extends StatelessWidget {
  // widget
  final int value; // qty
  final ValueChanged<int> onChanged; // callback
  const ParticipantsStepper({
    super.key,
    required this.value,
    required this.onChanged,
  }); // ctor

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme; // text
    return Row(
      children: [
        _btn(
          context,
          icon: Icons.remove,
          onTap: () => onChanged(value - 1),
        ), // minus
        const SizedBox(width: 12), // gap
        Text('$value', style: tt.titleMedium), // count
        const SizedBox(width: 12), // gap
        _btn(
          context,
          icon: Icons.add,
          onTap: () => onChanged(value + 1),
        ), // plus
      ],
    );
  }

  Widget _btn(
    BuildContext context, { // small button
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme; // colors
    return Material(
      color: cs.surface, // bg
      borderRadius: BorderRadius.circular(10), // round
      child: InkWell(
        onTap: onTap, // tap
        borderRadius: BorderRadius.circular(10), // ripple shape
        child: SizedBox(
          width: 44,
          height: 44, // size
          child: Icon(icon, size: 20), // icon
        ),
      ),
    );
  }
}
