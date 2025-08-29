import 'package:flutter/material.dart';

class CardBanner extends StatelessWidget {
  const CardBanner({super.key, this.imageUrl, this.onTap});
  final String? imageUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: imageUrl == null
            ? Container(
                color: const Color(0xFFE5E7EB),
                child: const Center(child: Icon(Icons.image, size: 40)),
              )
            : Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFE5E7EB),
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 40),
                  ),
                ),
              ),
      ),
    );
  }
}
