import 'package:flutter/material.dart';

class BusinessProfileMenu extends StatelessWidget {
  final List<({IconData icon, String label, VoidCallback onTap})> items;

  const BusinessProfileMenu({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (it) => ListTile(
              leading: Icon(it.icon),
              title: Text(it.label),
              onTap: it.onTap,
            ),
          )
          .toList(),
    );
  }
}
