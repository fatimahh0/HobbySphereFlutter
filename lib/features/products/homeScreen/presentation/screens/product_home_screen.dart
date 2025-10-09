// Product Home Screen
// Very simple grid of fake products to prove the shell + routing work.
// You can replace with real BLoC/repository calls later.

import 'package:flutter/material.dart';

class ProductHomeScreen extends StatelessWidget {
  const ProductHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // fake products
    final products = List.generate(12, (i) => 'Product #${i + 1}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products Home'), // page title
        centerTitle: true, // center
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12), // outer padding
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 per row
          mainAxisSpacing: 12, // spacing Y
          crossAxisSpacing: 12, // spacing X
          childAspectRatio: 0.78, // card aspect
        ),
        itemCount: products.length, // number of tiles
        itemBuilder: (_, i) {
          final title = products[i]; // product title
          return Card(
            elevation: 0, // flat
            clipBehavior: Clip.antiAlias, // clip image radius
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16), // round corners
              side: BorderSide(
                color: Theme.of(context).dividerColor, // subtle border
              ),
            ),
            child: InkWell(
              onTap: () {
                // TODO: go to details later
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Open $title')));
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // placeholder image
                  Expanded(
                    child: Container(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.inventory_2_outlined, size: 56),
                    ),
                  ),
                  // title + price row
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '\$ ${(i + 1) * 9}.99',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
