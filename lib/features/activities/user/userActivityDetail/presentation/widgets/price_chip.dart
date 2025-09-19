import 'package:flutter/material.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:hobby_sphere/shared/utils/currency_utils.dart';

class PriceChip extends StatelessWidget {
  final num price; // price value
  final String? currencyCode; // currency
  const PriceChip({super.key, required this.price, this.currencyCode});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme; // colors
    final tt = Theme.of(context).textTheme; // text
    final t = AppLocalizations.of(context)!; // l10n

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ), // space
      decoration: BoxDecoration(
        color: cs.surface, // THEMED bg
        borderRadius: BorderRadius.circular(12), // round
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // wrap
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 18,
            color: cs.primary, // THEMED (was green)
          ),
          const SizedBox(width: 6),
          Text(
            '${formatPrice(price, currencyCode)} ${t.bookingPerPerson}', // text
            style: tt.bodyMedium, // THEMED text
          ),
        ],
      ),
    );
  }
}
