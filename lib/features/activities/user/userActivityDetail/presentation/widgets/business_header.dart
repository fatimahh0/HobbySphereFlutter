// Small card showing business info                                   // file role
import 'package:flutter/material.dart'; // ui
import '../../domain/entities/user_activity_detail_entity.dart'; // entity

class BusinessHeader extends StatelessWidget {
  // widget
  final UserBusinessMini biz; // data
  final String? imageBaseUrl; // server base for relative logo
  const BusinessHeader({
    super.key,
    required this.biz,
    this.imageBaseUrl,
  }); // ctor

  String? _absolute(String? u) {
    // make absolute
    if (u == null || u.trim().isEmpty) return null; // guard
    if (u.startsWith('http')) return u; // already abs
    final base = (imageBaseUrl ?? '').trim(); // base
    if (base.isEmpty) return null; // no base
    final b = base.endsWith('/')
        ? base.substring(0, base.length - 1)
        : base; // trim last /
    final p = u.startsWith('/') ? u : '/$u'; // ensure /path
    return '$b$p'; // join
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme; // colors
    final tt = Theme.of(context).textTheme; // text
    final logo = _absolute(biz.logoUrl); // logo url
    return Container(
      padding: const EdgeInsets.all(12), // space
      decoration: BoxDecoration(
        color: cs.surface, // card bg
        borderRadius: BorderRadius.circular(16), // round
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20, // size
            backgroundColor: cs.secondaryContainer, // fallback bg
            backgroundImage: logo != null ? NetworkImage(logo) : null, // image
            child: logo == null
                ? const Icon(Icons.store_mall_directory_rounded) // placeholder
                : null,
          ),
          const SizedBox(width: 10), // gap
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // left
              children: [
                Text(biz.name, style: tt.titleMedium), // name
                if ((biz.description ?? '').isNotEmpty) // optional
                  Text(
                    biz.description!, // tagline
                    style: tt.bodyMedium?.copyWith(color: cs.outline),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
