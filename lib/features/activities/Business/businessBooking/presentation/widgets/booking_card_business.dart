// ===== Flutter 3.35.x =====
// BookingCardBusiness — professional booking card UI
// Responsive, supports currency, wraps date, no overflow.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:hobby_sphere/shared/theme/app_theme.dart';
import 'package:hobby_sphere/shared/widgets/app_button.dart';

import '../../domain/entities/business_booking.dart';
import '../bloc/business_booking_bloc.dart';
import '../bloc/business_booking_event.dart';

class BookingCardBusiness extends StatelessWidget {
  final BusinessBooking booking;
  const BookingCardBusiness({super.key, required this.booking});

  // === Handle both network & local images ===
  Widget _buildImage(String? url) {
    if (url == null || url.isEmpty) {
      return Container(
        color: Colors.grey.shade200,
        child: const Icon(Icons.image_not_supported, size: 40),
      );
    }
    if (url.startsWith("http")) {
      return Image.network(url, fit: BoxFit.cover);
    } else if (url.startsWith("file://")) {
      return Image.file(File(Uri.parse(url).path), fit: BoxFit.cover);
    } else {
      return const Icon(Icons.broken_image, size: 40);
    }
  }

  // === Status chip colors ===
  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.pending;
      case 'completed':
        return AppColors.completed;
      case 'rejected':
        return AppColors.rejected;
      case 'canceled':
        return AppColors.canceled;
      default:
        return AppColors.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==== HEADER (image + title + status) ====
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: _buildImage(booking.imageUrl),
                  ),
                ),
                const SizedBox(width: 12),

                // Title + Status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + Status row
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              booking.itemName ?? l10n.activitiesNoActivities,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Chip(
                            label: Text(
                              booking.status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            backgroundColor: _statusColor(booking.status),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 0,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Booked By + Date (wrap into 3 lines max)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundImage: booking.bookedByAvatar != null
                                ? NetworkImage(booking.bookedByAvatar!)
                                : null,
                            child: booking.bookedByAvatar == null
                                ? const Icon(Icons.person, size: 16)
                                : null,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  booking.bookedBy ?? "-",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  booking.dateFormatted,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 3, // ✅ wrap to max 3 lines
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ==== DETAILS ROW ====
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.group, size: 16),
                    const SizedBox(width: 4),
                    Text("${booking.participants} ${l10n.bookingParticipants}"),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.attach_money, size: 16),
                    const SizedBox(width: 2),
                    Text(
                      "${booking.currency?.symbol ?? ''}${booking.price.toStringAsFixed(2)} "
                      "(${booking.currency?.code ?? ''})",
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.credit_card, size: 16),
                    const SizedBox(width: 2),
                    Text(booking.paymentMethod),
                  ],
                ),
              ],
            ),

            if (booking.wasPaid)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  l10n.bookingsPaid,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.paid,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            const SizedBox(height: 12),

            // ==== ACTION BUTTONS ====
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (booking.status.toLowerCase() == 'pending')
                  AppButton(
                    label: l10n.bookingReject,
                    onPressed: () {
                      context.read<BusinessBookingBloc>().add(
                        RejectBooking(booking.id),
                      );
                    },
                    type: AppButtonType.outline,
                    size: AppButtonSize.sm,
                  ),
                if (booking.status.toLowerCase() == 'rejected')
                  AppButton(
                    label: l10n.bookingUnreject,
                    onPressed: () {
                      context.read<BusinessBookingBloc>().add(
                        UnrejectBooking(booking.id),
                      );
                    },
                    type: AppButtonType.text,
                    size: AppButtonSize.sm,
                  ),
                if (!booking.wasPaid)
                  AppButton(
                    label: l10n.markAsPaid,
                    onPressed: () {
                      context.read<BusinessBookingBloc>().add(
                        MarkPaidBooking(booking.id),
                      );
                    },
                    type: AppButtonType.secondary,
                    size: AppButtonSize.sm,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
