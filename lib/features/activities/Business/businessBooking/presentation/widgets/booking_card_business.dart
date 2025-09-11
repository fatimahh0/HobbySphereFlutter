// ===== Flutter 3.35.x =====
// BookingCardBusiness — ULTRA-COMPACT layout (everything smaller).
// Title smaller; "Booked by" + name + Status => same font size.

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

  // ===== ULTRA tokens =====
  static const double _pad = 6;
  static const double _marginV = 4;
  static const double _img = 56;
  static const double _radius = 10;
  static const double _gap = 4;
  static const double _gapSm = 2;
  static const double _icon = 12;
  static const double _avatar = 12;

  // Fonts
  static const double _fsTitle = 12; // smaller title
  static const double _fsUnified = 11; // Booked-by + name + status
  static const double _fsInfo = 11; // details rows
  static const double _lsTight = -0.1; // slight negative letter spacing
  static const double _lhTight = 1.05; // tight line-height

  // Chip density
  static const _chipDensity = VisualDensity(horizontal: -4, vertical: -4);

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
        child: const Icon(Icons.image_not_supported, size: 30),
      );
    }
    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 30),
      );
    } else if (url.startsWith('file://')) {
      return Image.file(
        File(Uri.parse(url).path),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 30),
      );
    } else {
      return const Icon(Icons.broken_image, size: 30);
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
        Icon(icon, size: _icon, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: _gapSm),
        if ((label ?? '').isNotEmpty)
          Text(
            "$label: ",
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: _fsInfo,
              height: _lhTight,
              letterSpacing: _lsTight,
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: _fsInfo,
              height: _lhTight,
              letterSpacing: _lsTight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
          ),
        ),
      ],
    );
  }

  Widget _chip(
    BuildContext context, {
    required String text,
    required Color bg,
    required Color fg,
    bool bold = true,
  }) {
    return Chip(
      backgroundColor: bg,
      label: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: _fsUnified,
          height: _lhTight,
          letterSpacing: _lsTight,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      visualDensity: _chipDensity,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
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
    return _chip(context, text: method, bg: bg, fg: fg, bold: true);
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
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: _marginV),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radius),
      ),
      elevation: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(_pad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== Header =====
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(_radius),
                  child: SizedBox(
                    width: _img,
                    height: _img,
                    child: _buildImage(booking.imageUrl),
                  ),
                ),
                const SizedBox(width: _gap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title (smaller, 1 line)
                      Text(
                        booking.itemName ?? l10n.activitiesNoActivities,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: _fsTitle,
                          height: _lhTight,
                          letterSpacing: _lsTight,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: _gapSm),

                      // Booked by (unified size)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: _avatar,
                            backgroundImage: booking.bookedByAvatar != null
                                ? NetworkImage(booking.bookedByAvatar!)
                                : null,
                            child: booking.bookedByAvatar == null
                                ? const Icon(Icons.person, size: 14)
                                : null,
                          ),
                          const SizedBox(width: _gap),
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  flex: 0,
                                  child: Text(
                                    "${l10n.bookingsByUser} ",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontSize: _fsUnified,
                                      height: _lhTight,
                                      letterSpacing: _lsTight,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    booking.bookedBy ?? '-',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontSize: _fsUnified,
                                      height: _lhTight,
                                      letterSpacing: _lsTight,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: _gapSm),

                      // Status + Paid + Method (same size as name)
                      Wrap(
                        spacing: _gapSm,
                        runSpacing: _gapSm,
                        children: [
                          _chip(
                            context,
                            text: booking.status,
                            bg: _statusColor(booking.status),
                            fg: Colors.white,
                            bold: true,
                          ),
                          if (booking.wasPaid)
                            _chip(
                              context,
                              text: l10n.bookingsPaid,
                              bg: theme.colorScheme.primaryContainer,
                              fg: theme.colorScheme.onPrimaryContainer,
                              bold: true,
                            ),
                          _methodChip(context, booking.paymentMethod),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: _gap),

            // ===== Details =====
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.25),
                borderRadius: BorderRadius.circular(_radius),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Column(
                children: [
                  if ((booking.eventDateFormatted ?? '').isNotEmpty)
                    _infoRow(
                      context: context,
                      icon: Icons.event,
                      value: booking.eventDateFormatted!,
                    ),
                  if ((booking.itemLocation ?? '').isNotEmpty) ...[
                    const SizedBox(height: _gap),
                    _infoRow(
                      context: context,
                      icon: Icons.place_rounded,
                      label: l10n.bookingLocation,
                      value: booking.itemLocation!,
                    ),
                  ],
                  const SizedBox(height: _gap),
                  _infoRow(
                    context: context,
                    icon: Icons.group_rounded,
                    label: l10n.bookingParticipants,
                    value: booking.participants.toString(),
                  ),
                  const SizedBox(height: _gap),
                  _infoRow(
                    context: context,
                    icon: Icons.payments_rounded,
                    label: l10n.bookingPaymentMethod,
                    value: booking.paymentMethod,
                  ),
                  const SizedBox(height: _gap),
                  _infoRow(
                    context: context,
                    icon: Icons.attach_money_rounded,
                    label: l10n.bookingTotalPrice,
                    value: booking.totalFormatted,
                  ),
                ],
              ),
            ),

            const SizedBox(height: _gap),

            // ===== Actions =====
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
                    if (status == 'rejected') ...[
                      const SizedBox(width: _gapSm),
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
                    ],
                    if (status == 'cancel_requested') ...[
                      const SizedBox(width: _gapSm),
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
                      const SizedBox(width: _gapSm),
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
                      const SizedBox(width: _gapSm),
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
                      const SizedBox(width: _gap),
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 1.8),
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
