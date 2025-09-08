import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';

class BusinessListItemCard extends StatelessWidget {
  final String id;
  final String title;
  final DateTime? startDate;
  final String location;
  final String? imageUrl;
  final VoidCallback? onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onReopen; // ✅ new for terminated items

  const BusinessListItemCard({
    super.key,
    required this.id,
    required this.title,
    required this.location,
    this.startDate,
    this.imageUrl,
    this.onView,
    this.onEdit,
    this.onDelete,
    this.onReopen,
  });

  /// Build image widget safely (supports local File or remote URL)
  Widget _buildImage(double size, ColorScheme cs) {
    Widget img;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      if (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://')) {
        img = Image.network(
          imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackIcon(size, cs),
        );
      } else {
        final file = File(imageUrl!);
        if (file.existsSync()) {
          img = Image.file(
            file,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _fallbackIcon(size, cs),
          );
        } else {
          img = _fallbackIcon(size, cs);
        }
      }
    } else {
      img = _fallbackIcon(size, cs);
    }

    // ✅ Rounded (circle)
    return ClipOval(child: img);
  }

  /// Fallback icon if no image
  Widget _fallbackIcon(double size, ColorScheme cs) {
    return Container(
      width: size,
      height: size,
      color: cs.primary.withOpacity(0.15),
      child: Icon(Icons.business, color: cs.primary, size: size * 0.6),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    const double imageSize = 64;

    return Slidable(
      key: ValueKey(id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          if (onEdit != null)
            SlidableAction(
              onPressed: (_) => onEdit?.call(),
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              icon: Icons.edit,
            ),
          if (onDelete != null)
            SlidableAction(
              onPressed: (_) => onDelete?.call(),
              backgroundColor: cs.error,
              foregroundColor: cs.onError,
              icon: Icons.delete,
            ),
          if (onReopen != null)
            SlidableAction(
              onPressed: (_) => onReopen?.call(),
              backgroundColor: cs.secondary,
              foregroundColor: cs.onSecondary,
              icon: Icons.refresh,
            ),
        ],
      ),
      child: InkWell(
        onTap: onView,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: cs.surface,
            border: Border(
              bottom: BorderSide(color: cs.outlineVariant, width: 0.8),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildImage(imageSize, cs),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      title,
                      style: tt.titleMedium?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Date
                    if (startDate != null)
                      Text(
                        MaterialLocalizations.of(
                          context,
                        ).formatShortDate(startDate!),
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                    // Location
                    Text(
                      location,
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
