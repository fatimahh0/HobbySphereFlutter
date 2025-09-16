import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hobby_sphere/shared/theme/app_theme.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';
import '../../../tickets/domain/entities/booking_entity.dart';

typedef CancelWithReason = void Function(int bookingId, String reason);

class TicketCard extends StatelessWidget {
  final BookingEntity booking;
  final CancelWithReason? onCancel;
  final String? imageBaseUrl; // to resolve /uploads/...

  const TicketCard({
    super.key,
    required this.booking,
    this.onCancel,
    this.imageBaseUrl,
  });

  String? _absolute(String? u) {
    if (u == null || u.trim().isEmpty) return null;
    final url = u.trim();
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    final base = (imageBaseUrl ?? '').trim();
    if (base.isEmpty) return null;
    final baseClean = base.endsWith('/')
        ? base.substring(0, base.length - 1)
        : base;
    final path = url.startsWith('/') ? url : '/$url';
    return '$baseClean$path';
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'Pending':
      case 'CancelRequested':
        return AppColors.pending;
      case 'Completed':
        return AppColors.completed;
      case 'Canceled':
        return AppColors.canceled;
      default:
        return AppColors.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final time = booking.startDatetime != null
        ? DateFormat('hh:mm a').format(booking.startDatetime!)
        : '—';
    final date = booking.startDatetime != null
        ? DateFormat('EEE, d MMM').format(booking.startDatetime!)
        : '—';

    final img = _absolute(booking.imageUrl);

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(14),
      elevation: 0, // flatter
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: cs.outlineVariant),
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(10), // tighter
        child: Column(
          children: [
            Row(
              children: [
                // smaller thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 40,
                    height: 40,
                    color: Colors.black12,
                    child: img == null
                        ? const Icon(
                            Icons.image_not_supported_outlined,
                            size: 18,
                          )
                        : Image.network(
                            img,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.image_not_supported_outlined,
                              size: 18,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 8),
                // title + location
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.itemName,
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        booking.location,
                        style: tt.bodySmall?.copyWith(color: AppColors.muted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // no divider to save height
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // time
                Expanded(
                  child: _kv(
                    context,
                    label: t.ticketTime,
                    value: time,
                    sub: date,
                  ),
                ),
                // location (just the label to match small layout)
                Expanded(
                  child: _kv(
                    context,
                    label: t.ticketLocation,
                    value: booking.location,
                  ),
                ),
                // small status pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(booking.bookingStatus),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${booking.bookingStatus} × ${booking.numberOfParticipants}',
                    style: tt.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            if (booking.bookingStatus == 'Pending') ...[
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => _askReason(context),
                  child: Text(
                    t.ticketCancel,
                    style: tt.labelSmall?.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _kv(
    BuildContext context, {
    required String label,
    required String value,
    String? sub,
  }) {
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: tt.bodySmall?.copyWith(color: AppColors.muted, fontSize: 11),
        ),
        const SizedBox(height: 1),
        Text(value, style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
        if (sub != null)
          Text(
            sub,
            style: tt.bodySmall?.copyWith(color: AppColors.muted, fontSize: 11),
          ),
      ],
    );
  }

  Future<void> _askReason(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    bool touched = false;

    final reason = await showDialog<String?>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.ticketCancelTitle),
        content: StatefulBuilder(
          builder: (context, setState) => TextField(
            controller: controller,
            maxLines: 3,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: t.bookingCancelReason,
              hintText: t.bookingCancelReason,
              errorText: touched && controller.text.trim().isEmpty
                  ? t.fieldRequired
                  : null,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: Text(t.buttonCancel),
          ),
          TextButton(
            onPressed: () {
              touched = true;
              if (controller.text.trim().isEmpty) {
                (context as Element).markNeedsBuild();
                return;
              }
              Navigator.pop(context, controller.text.trim());
            },
            child: Text(t.buttonConfirm),
          ),
        ],
      ),
    );

    if (reason != null && reason.isNotEmpty) {
      onCancel?.call(booking.id, reason);
    }
  }
}
