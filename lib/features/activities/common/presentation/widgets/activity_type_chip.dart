// Small pressable card for one category
import 'package:flutter/material.dart';
import 'package:hobby_sphere/shared/theme/app_theme.dart'; // AppColors
import 'icon_mapper.dart'; // icon mapper

class ActivityTypeChip extends StatelessWidget {
  final String label;
  final String? iconName;
  final VoidCallback? onTap;

  const ActivityTypeChip({
    super.key,
    required this.label,
    this.iconName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(
            // slightly tighter to fit inside short tiles comfortably
            horizontal: 10,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: cs.outlineVariant),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                mapIoniconsToMaterial(iconName),
                size: 20,
                color: AppColors.muted,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: tt.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
