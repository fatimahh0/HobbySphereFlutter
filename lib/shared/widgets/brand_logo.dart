// lib/shared/widgets/brand_logo.dart
import 'package:flutter/material.dart';
import 'package:hobby_sphere/config/env.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 40});
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = Env.appLogoUrl.trim();
    if (url.isEmpty) {
      return Icon(Icons.apps, size: size);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.2),
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Icon(Icons.image_not_supported, size: size),
      ),
    );
  }
}
