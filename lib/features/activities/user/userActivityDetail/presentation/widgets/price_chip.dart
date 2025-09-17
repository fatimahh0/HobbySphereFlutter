// Gray chip to show price per person                                 // file role
import 'package:flutter/material.dart'; // ui
import 'package:hobby_sphere/shared/utils/currency_utils.dart'; // formatter

class PriceChip extends StatelessWidget {
  // widget
  final num price; // value
  final String? currencyCode; // code (CAD, USD…)
  const PriceChip({super.key, required this.price, this.currencyCode}); // ctor

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme; // colors
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ), // space
      decoration: BoxDecoration(
        color: cs.surface, // bg
        borderRadius: BorderRadius.circular(12), // round
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // wrap
        children: [
          const Icon(
            Icons.local_offer_outlined,
            size: 18,
            color: Colors.green,
          ), // icon
          const SizedBox(width: 6), // gap
          Text('${formatPrice(price, currencyCode)} / person'), // text
        ],
      ),
    );
  }
}
