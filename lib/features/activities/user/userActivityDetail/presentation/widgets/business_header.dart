import 'package:flutter/material.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';
import '../../domain/entities/user_activity_detail_entity.dart';

class BusinessHeader extends StatelessWidget {
  final UserBusinessMini biz; // business mini entity
  final String? imageBaseUrl; // base for img
  const BusinessHeader({super.key, required this.biz, this.imageBaseUrl});

  // make absolute url
  String? _absolute(String? u) {
    if (u == null || u.trim().isEmpty) return null; // no url
    if (u.startsWith('http')) return u; // already abs
    final base = (imageBaseUrl ?? '').trim(); // base
    if (base.isEmpty) return null; // no base
    final b = base.endsWith('/')
        ? base.substring(0, base.length - 1)
        : base; // trim /
    final p = u.startsWith('/') ? u : '/$u'; // ensure /
    return '$b$p'; // join
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme; // colors
    final tt = Theme.of(context).textTheme; // text
    final t = AppLocalizations.of(context)!; // l10n
    final logo = _absolute(biz.logoUrl); // logo url

    return Container(
      padding: const EdgeInsets.all(12), // padding
      decoration: BoxDecoration(
        color: cs.surface, // THEMED card bg
        borderRadius: BorderRadius.circular(16), // round
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20, // avatar size
            backgroundColor: cs.secondaryContainer, // THEMED bg
            backgroundImage: logo != null ? NetworkImage(logo) : null, // image
            child: logo == null
                ? Icon(
                    Icons.store_mall_directory_rounded,
                    color: cs.onSecondaryContainer, // THEMED icon
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // left align
              children: [
                Text(
                  biz.name.isEmpty ? t.activitiesUnnamed : biz.name, // name
                  style: tt.titleMedium, // title style
                ),
                if ((biz.description ?? '').isNotEmpty)
                  Text(
                    biz.description!, // desc
                    style: tt.bodyMedium?.copyWith(
                      color: cs.outline,
                    ), // THEMED muted
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
