import 'package:flutter/material.dart';

class ActionsRow extends StatelessWidget {
  const ActionsRow({
    super.key,
    this.onView,
    this.onEdit,
    this.onDelete,
    required this.deleteColor,
  });

  final VoidCallback? onView, onEdit, onDelete;
  final Color deleteColor;

  static const _constraints = BoxConstraints.tightFor(width: 36, height: 36);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: 'View details',
          onPressed: onView,
          icon: const Icon(Icons.remove_red_eye_outlined, size: 20),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: _constraints,
        ),
        const SizedBox(width: 6),
        IconButton(
          tooltip: 'Edit',
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined, size: 20),
          color: Colors.green,
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: _constraints,
        ),
        const Spacer(),
        IconButton(
          tooltip: 'Delete',
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline, size: 20),
          color: deleteColor,
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: _constraints,
        ),
      ],
    );
  }
}
