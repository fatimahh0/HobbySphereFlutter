import 'package:flutter/material.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';

/// RoleSelector renders two pills: User / Business.
/// - [value] = 0 => User, 1 => Business
/// - [onChanged] is called with 0 or 1
class RoleSelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const RoleSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _RolePill(
          label: t.loginUser,           // <-- text shows here
          selected: value == 0,
          onTap: () => onChanged(0),
        ),
        const SizedBox(width: 12),
        _RolePill(
          label: t.loginBusiness,       // <-- and here
          selected: value == 1,
          onTap: () => onChanged(1),
        ),
      ],
    );
  }
}

class _RolePill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RolePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final bg = selected ? cs.primary.withOpacity(.25) : cs.surface;
    final fg = selected ? cs.primary : cs.onSurface.withOpacity(.85);
    final br = selected ? Colors.transparent : cs.outlineVariant;

    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: br, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelLarge?.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
              letterSpacing: .2,
            ),
          ),
        ),
      ),
    );
  }
}
