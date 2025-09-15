import 'package:flutter/material.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:hobby_sphere/shared/widgets/app_button.dart';

import '../../../domain/entities/activity_type.dart';
import 'interest_icon_resolver.dart';

class InterestsGridRemote extends StatelessWidget {
  final List<ActivityType> items;
  final Set<int> selected;
  final bool showAll;
  final VoidCallback onToggleShow;
  final void Function(int) onToggle;
  final VoidCallback onSubmit;

  const InterestsGridRemote({
    super.key,
    required this.items,
    required this.selected,
    required this.showAll,
    required this.onToggleShow,
    required this.onToggle,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final list = showAll ? items : items.take(6).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          t.interestTitle, // "What are you into?"
          textAlign: TextAlign.center,
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: list.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.6,
          ),
          itemBuilder: (_, i) {
            final it = list[i];
            final active = selected.contains(it.id);
            final iconData = interestIcon(it.iconLib, it.icon);

            return InkWell(
              onTap: () => onToggle(it.id),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active ? cs.primary : cs.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: active ? cs.primary : cs.outlineVariant,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      iconData,
                      size: 20,
                      color: active ? cs.onPrimary : cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        it.name,
                        overflow: TextOverflow.ellipsis,
                        style: tt.titleMedium?.copyWith(
                          color: active ? cs.onPrimary : cs.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: onToggleShow,
            child: Text(showAll ? t.buttonsSeeLess : t.buttonsSeeAll),
          ),
        ),
        const SizedBox(height: 8),
        AppButton(
          onPressed: onSubmit,
          label: t.interestContinue, // "Continue"
          expand: true,
        ),
      ],
    );
  }
}
