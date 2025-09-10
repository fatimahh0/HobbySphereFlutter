// ===== Flutter 3.35.x =====
// BookingCardBusiness — reject/unreject + approve/reject cancel

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
      case 'cancel_requested':
        return Colors.orange;
      default:
        return AppColors.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final status = booking.status.trim().toLowerCase();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==== HEADER ====
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: _buildImage(booking.imageUrl),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
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
                                  maxLines: 3,
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

            // ==== ACTION BUTTONS ====
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (status == 'pending')
                  AppButton(
                    label: l10n.bookingReject,
                    onPressed: () => context.read<BusinessBookingBloc>().add(
                      RejectBooking(booking.id),
                    ),
                    type: AppButtonType.outline,
                    size: AppButtonSize.sm,
                  ),
                if (status == 'rejected')
                  AppButton(
                    label: l10n.bookingUnreject,
                    onPressed: () => context.read<BusinessBookingBloc>().add(
                      UnrejectBooking(booking.id),
                    ),
                    type: AppButtonType.text,
                    size: AppButtonSize.sm,
                  ),
                if (status == 'cancel_requested') ...[
                  AppButton(
                    label: l10n.bookingConfirm_approveCancel,
                    onPressed: () => context.read<BusinessBookingBloc>().add(
                      ApproveCancelBooking(booking.id),
                    ),
                    type: AppButtonType.secondary,
                    size: AppButtonSize.sm,
                  ),
                  const SizedBox(width: 6),
                  AppButton(
                    label: l10n.bookingRejectCancel,
                    onPressed: () => context.read<BusinessBookingBloc>().add(
                      RejectCancelBooking(booking.id),
                    ),
                    type: AppButtonType.outline,
                    size: AppButtonSize.sm,
                  ),
                ],
                if (!booking.wasPaid)
                  AppButton(
                    label: l10n.markAsPaid,
                    onPressed: () => context.read<BusinessBookingBloc>().add(
                      MarkPaidBooking(booking.id),
                    ),
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
