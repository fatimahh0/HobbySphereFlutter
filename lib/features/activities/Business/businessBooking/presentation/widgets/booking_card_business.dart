// ===== Flutter 3.35.x =====
// BookingCardBusiness — show full user name, hide booking ID, keep actions/busy state.

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

  Future<bool> _confirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(AppLocalizations.of(context)!.bookingCancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(confirmLabel),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget _buildImage(String? url) {
    if (url == null || url.isEmpty) {
      return Container(
        color: Colors.grey.shade200,
        child: const Icon(Icons.image_not_supported, size: 40),
      );
    }
    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 40),
      );
    } else if (url.startsWith('file://')) {
      return Image.file(
        File(Uri.parse(url).path),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 40),
      );
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

  Widget _infoRow({
    required BuildContext context,
    required IconData icon,
    String? label,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        if ((label ?? '').isNotEmpty)
          Text(
            "$label: ",
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall,
            softWrap: true,
            maxLines: 3, // ← allow wrapping instead of ellipsis
          ),
        ),
      ],
    );
  }

  Widget _methodChip(BuildContext context, String method) {
    final theme = Theme.of(context);
    final isCash = method.toLowerCase() == 'cash';
    final bg = isCash
        ? theme.colorScheme.tertiaryContainer
        : theme.colorScheme.secondaryContainer;
    final fg = isCash
        ? theme.colorScheme.onTertiaryContainer
        : theme.colorScheme.onSecondaryContainer;
    return Chip(
      backgroundColor: bg,
      label: Text(
        method,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600),
      ),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 6),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final status = booking.status.toLowerCase();

    final isBusy = context.select<BusinessBookingBloc, bool>(
      (b) => b.state.busyIds.contains(booking.id),
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === Header ===
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 84,
                    height: 84,
                    child: _buildImage(booking.imageUrl),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Item name
                      Text(
                        booking.itemName ?? l10n.activitiesNoActivities,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Booked-by block (FULL NAME, no ID)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundImage: booking.bookedByAvatar != null
                                ? NetworkImage(booking.bookedByAvatar!)
                                : null,
                            child: booking.bookedByAvatar == null
                                ? const Icon(Icons.person, size: 18)
                                : null,
                          ),
                          const SizedBox(width: 8),
                          // Show the full name (wrap up to 2–3 lines)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Optional small label
                                Text(
                                  l10n.bookingsByUser,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  booking.bookedBy ?? '-',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  softWrap: true,
                                  maxLines: 3,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Status + Paid + Method
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          Chip(
                            backgroundColor: _statusColor(booking.status),
                            label: Text(
                              booking.status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                          ),
                          if (booking.wasPaid)
                            Chip(
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                              label: Text(
                                l10n.bookingsPaid,
                                style: TextStyle(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                            ),
                          _methodChip(context, booking.paymentMethod),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // === Details block (kept as-is; safe if values exist) ===
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                children: [
                  if ((booking.eventDateFormatted ?? '').isNotEmpty)
                    _infoRow(
                      context: context,
                      icon: Icons.event,
                      value: booking.eventDateFormatted!,
                    ),
                  if ((booking.itemLocation ?? '').isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _infoRow(
                      context: context,
                      icon: Icons.place_rounded,
                      label: l10n.bookingLocation,
                      value: booking.itemLocation!,
                    ),
                  ],
                  const SizedBox(height: 8),
                  _infoRow(
                    context: context,
                    icon: Icons.group_rounded,
                    label: l10n.bookingParticipants,
                    value: booking.participants.toString(),
                  ),
                  const SizedBox(height: 8),
                  _infoRow(
                    context: context,
                    icon: Icons.payments_rounded,
                    label: l10n.bookingPaymentMethod,
                    value: booking.paymentMethod,
                  ),
                  const SizedBox(height: 8),
                  _infoRow(
                    context: context,
                    icon: Icons.attach_money_rounded,
                    label: l10n.bookingTotalPrice,
                    value: booking.totalFormatted,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // === Actions (disabled when busy) ===
            AbsorbPointer(
              absorbing: isBusy,
              child: Opacity(
                opacity: isBusy ? 0.6 : 1.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (status == 'pending')
                      AppButton(
                        label: l10n.bookingReject,
                        onPressed: () async {
                          final ok = await _confirmDialog(
                            context: context,
                            title: l10n.bookingConfirmRejectTitle,
                            message: l10n.bookingConfirmRejectMessage,
                            confirmLabel: l10n.bookingConfirm_reject,
                          );
                          if (ok) {
                            context.read<BusinessBookingBloc>().add(
                              RejectBooking(booking.id),
                            );
                          }
                        },
                        type: AppButtonType.outline,
                        size: AppButtonSize.sm,
                      ),
                    if (status == 'rejected')
                      AppButton(
                        label: l10n.bookingUnreject,
                        onPressed: () async {
                          final ok = await _confirmDialog(
                            context: context,
                            title: l10n.bookingConfirmUnrejectTitle,
                            message: l10n.bookingConfirmUnrejectMessage,
                            confirmLabel: l10n.bookingConfirm_unreject,
                          );
                          if (ok) {
                            context.read<BusinessBookingBloc>().add(
                              UnrejectBooking(booking.id),
                            );
                          }
                        },
                        type: AppButtonType.text,
                        size: AppButtonSize.sm,
                      ),
                    if (status == 'cancel_requested') ...[
                      AppButton(
                        label: l10n.bookingConfirm_approveCancel,
                        onPressed: () async {
                          final ok = await _confirmDialog(
                            context: context,
                            title: l10n.bookingConfirm_approveCancel,
                            message: l10n.bookingMessage_approveCancel,
                            confirmLabel: l10n.bookingApprove,
                          );
                          if (ok) {
                            context.read<BusinessBookingBloc>().add(
                              ApproveCancelBooking(booking.id),
                            );
                          }
                        },
                        type: AppButtonType.secondary,
                        size: AppButtonSize.sm,
                      ),
                      const SizedBox(width: 6),
                      AppButton(
                        label: l10n.bookingRejectCancel,
                        onPressed: () async {
                          final ok = await _confirmDialog(
                            context: context,
                            title: l10n.bookingConfirm_rejectCancel,
                            message: l10n.bookingMessage_rejectCancel,
                            confirmLabel: l10n.bookingConfirm_reject,
                          );
                          if (ok) {
                            context.read<BusinessBookingBloc>().add(
                              RejectCancelBooking(booking.id),
                            );
                          }
                        },
                        type: AppButtonType.outline,
                        size: AppButtonSize.sm,
                      ),
                    ],
                    if (!booking.wasPaid) ...[
                      const SizedBox(width: 6),
                      AppButton(
                        label: l10n.bookingsMarkPaid,
                        onPressed: () async {
                          final ok = await _confirmDialog(
                            context: context,
                            title: l10n.bookingsPaid,
                            message: l10n.bookingProcessing,
                            confirmLabel: l10n.bookingApprove,
                          );
                          if (ok) {
                            context.read<BusinessBookingBloc>().add(
                              MarkPaidBooking(booking.id),
                            );
                          }
                        },
                        type: AppButtonType.secondary,
                        size: AppButtonSize.sm,
                      ),
                    ],
                    if (isBusy) ...[
                      const SizedBox(width: 10),
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
