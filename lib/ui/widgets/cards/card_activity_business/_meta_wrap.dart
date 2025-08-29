import 'package:flutter/material.dart';
import 'card_activity_utils.dart';

class MetaWrap extends StatelessWidget {
  const MetaWrap({
    super.key,
    required this.date,
    required this.participants,
    required this.participantsLabel,
  });

  final DateTime? date;
  final int participants;
  final String participantsLabel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    Widget item(IconData icon, String text) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.event_outlined,
          size: 18,
          color: Color(0xFF6B7280),
        ).copyWith(icon: icon),
        const SizedBox(width: 6),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 220),
          child: Text(
            text,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: tt.bodySmall?.copyWith(
              color: cs.onSurface.withOpacity(0.85),
            ),
          ),
        ),
      ],
    );

    return Wrap(
      spacing: 12,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        item(Icons.event_outlined, fmtDate(date)),
        item(Icons.people_outline, '$participants $participantsLabel'),
      ],
    );
  }
}

extension on Icon {
  Icon copyWith({IconData? icon}) =>
      Icon(icon ?? this.icon, size: size, color: color);
}
