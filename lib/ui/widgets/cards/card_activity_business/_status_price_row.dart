import 'package:flutter/material.dart';

class StatusPriceRow extends StatelessWidget {
  const StatusPriceRow({
    super.key,
    required this.status,
    required this.chipColor,
    required this.price,
    this.priceTextStyle,
  });

  final String status;
  final Color chipColor;
  final String price;
  final TextStyle? priceTextStyle;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: chipColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: chipColor.withOpacity(0.35)),
          ),
          child: Text(
            status.isEmpty
                ? '—'
                : '${status[0].toUpperCase()}${status.substring(1)}',
            style: tt.labelMedium?.copyWith(
              color: chipColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const Spacer(),
        Flexible(
          child: Align(
            alignment: Alignment.centerRight,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                price,
                maxLines: 1,
                style: priceTextStyle ?? tt.titleMedium,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
