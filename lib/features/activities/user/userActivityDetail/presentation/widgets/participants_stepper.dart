import 'package:flutter/material.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';

class ParticipantsStepper extends StatelessWidget {
  final int value; // current value
  final ValueChanged<int> onChanged; // change callback
  const ParticipantsStepper({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme; // text theme
    final t = AppLocalizations.of(context)!; // l10n

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // left
      children: [
        Text(t.bookingParticipants, style: tt.titleMedium), // title
        const SizedBox(height: 10),
        Row(
          children: [
            _btn(
              context,
              icon: Icons.remove, // minus
              onTap: () => onChanged(value > 1 ? value - 1 : 1), // dec
            ),
            const SizedBox(width: 12),
            Text('$value', style: tt.titleMedium), // value
            const SizedBox(width: 12),
            _btn(
              context,
              icon: Icons.add, // plus
              onTap: () => onChanged(value + 1), // inc
            ),
          ],
        ),
      ],
    );
  }

  // small square button, themed
  Widget _btn(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme; // colors
    return Material(
      color: cs.surface, // THEMED bg
      borderRadius: BorderRadius.circular(10), // round
      child: InkWell(
        onTap: onTap, // tap
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, size: 20, color: cs.onSurface), // THEMED icon
        ),
      ),
    );
  }
}
