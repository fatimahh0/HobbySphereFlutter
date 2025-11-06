// lib/features/activities/Business/businessBooking/presentation/widgets/booking_card_business.dart
//// Flutter 3.35.x
//// Compact booking card for business with normalized status handling

import 'dart:io'; // File for local images
import 'package:flutter/material.dart'; // UI
import 'package:flutter_bloc/flutter_bloc.dart'; // Bloc
import 'package:hobby_sphere/l10n/app_localizations.dart'; // i18n
import 'package:hobby_sphere/shared/theme/app_colors.dart';
import 'package:hobby_sphere/shared/theme/app_theme.dart'; // AppColors
import 'package:hobby_sphere/shared/widgets/app_button.dart'; // AppButton

import '../../domain/entities/business_booking.dart'; // entity
import '../bloc/business_booking_bloc.dart'; // bloc
import '../bloc/business_booking_event.dart'; // events

class BookingCardBusiness extends StatelessWidget {
  // card input
  final BusinessBooking booking; // booking to render

  // ctor
  const BookingCardBusiness({super.key, required this.booking}); // ctor

  // layout tokens (compact)
  static const double _pad = 6; // inner padding
  static const double _marginV = 4; // vertical margin
  static const double _img = 56; // image size
  static const double _radius = 10; // radius
  static const double _gap = 4; // gap
  static const double _gapSm = 2; // small gap
  static const double _icon = 12; // icon size
  static const double _avatar = 12; // avatar radius
  static const double _fsTitle = 12; // title font size
  static const double _fsUnified = 11; // chip/name font size
  static const double _fsInfo = 11; // info font size
  static const double _lsTight = -0.1; // letter spacing
  static const double _lhTight = 1.05; // line height
  static const _chipDensity = VisualDensity(
    horizontal: -4,
    vertical: -4,
  ); // tight chip

  // confirm dialog helper
  Future<bool> _confirmDialog({
    required BuildContext context, // ctx
    required String title, // title
    required String message, // message
    required String confirmLabel, // ok label
  }) async {
    // show dialog and return bool
    return await showDialog<bool>(
          context: context, // ctx
          builder: (_) => AlertDialog(
            title: Text(title), // title
            content: Text(message), // message
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false), // cancel
                child: Text(
                  AppLocalizations.of(context)!.bookingCancel,
                ), // label
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true), // ok
                child: Text(confirmLabel), // label
              ),
            ],
          ),
        ) ??
        false; // default false
  }

  // safe image builder (http/file/fallback)
  Widget _buildImage(String? url) {
    if (url == null || url.isEmpty) {
      // no image → placeholder
      return Container(
        color: Colors.grey.shade200, // grey bg
        child: const Icon(Icons.image_not_supported, size: 30), // icon
      );
    }
    if (url.startsWith('http')) {
      // remote image
      return Image.network(
        url, // url
        fit: BoxFit.cover, // cover
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.broken_image, size: 30), // on error
      );
    } else if (url.startsWith('file://')) {
      // local file
      return Image.file(
        File(Uri.parse(url).path), // file path
        fit: BoxFit.cover, // cover
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.broken_image, size: 30), // on error
      );
    } else {
      // unknown scheme
      return const Icon(Icons.broken_image, size: 30); // icon
    }
  }

  // status color by normalized key
  Color _statusColor(String key) {
    // key is like "cancelrequested"
    switch (key) {
      case 'pending': // pending
        return AppColors.pending;
      case 'completed': // completed
        return AppColors.completed;
      case 'rejected': // rejected
        return AppColors.rejected;
      case 'canceled': // canceled
      case 'cancelled': // alt spelling
      case 'cancelapproved': // approved cancel
        return AppColors.canceled;
      case 'cancelrequested': // waiting decision
        return Colors.orange;
      case 'cancelrejected': // cancel rejected
        return AppColors.rejected;
      default: // fallback
        return AppColors.muted;
    }
  }

  // info row builder
  Widget _infoRow({
    required BuildContext context, // ctx
    required IconData icon, // icon
    String? label, // optional label
    required String value, // value text
  }) {
    final theme = Theme.of(context); // theme
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start, // align start
      children: [
        Icon(
          icon,
          size: _icon,
          color: theme.colorScheme.onSurfaceVariant,
        ), // icon
        const SizedBox(width: _gapSm), // small gap
        if ((label ?? '').isNotEmpty) // if label exists
          Text(
            "$label: ", // label with colon
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: _fsInfo, // font size
              height: _lhTight, // line height
              letterSpacing: _lsTight, // spacing
              color: theme.colorScheme.onSurfaceVariant, // color
              fontWeight: FontWeight.w600, // weight
            ),
          ),
        Expanded(
          child: Text(
            value, // value
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: _fsInfo, // font size
              height: _lhTight, // line height
              letterSpacing: _lsTight, // spacing
            ),
            maxLines: 1, // one line
            overflow: TextOverflow.ellipsis, // ellipsis
            softWrap: false, // no wrap
          ),
        ),
      ],
    );
  }

  // small chip builder
  Widget _chip(
    BuildContext context, {
    required String text, // chip text
    required Color bg, // background
    required Color fg, // foreground
    bool bold = true, // bold flag
  }) {
    return Chip(
      backgroundColor: bg, // bg
      label: Text(
        text, // text
        style: TextStyle(
          color: fg, // fg
          fontSize: _fsUnified, // font size
          height: _lhTight, // line height
          letterSpacing: _lsTight, // spacing
          fontWeight: bold ? FontWeight.w700 : FontWeight.w600, // weight
        ),
        overflow: TextOverflow.ellipsis, // ellipsis
        maxLines: 1, // one line
      ),
      visualDensity: _chipDensity, // compact
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // tight
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0), // pad
    );
  }

  // chip for payment method
  Widget _methodChip(BuildContext context, String method) {
    final theme = Theme.of(context); // theme
    final isCash = method.toLowerCase() == 'cash'; // is cash?
    final bg = isCash
        ? theme.colorScheme.tertiaryContainer
        : theme.colorScheme.secondaryContainer; // bg color
    final fg = isCash
        ? theme.colorScheme.onTertiaryContainer
        : theme.colorScheme.onSecondaryContainer; // fg color
    return _chip(context, text: method, bg: bg, fg: fg, bold: true); // chip
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // strings
    final theme = Theme.of(context); // theme

    // 👉 use normalized key once
    final key = booking.statusKey; // e.g., "cancelrequested"

    // read busy flag from bloc (per id)
    final isBusy = context.select<BusinessBookingBloc, bool>(
      (b) => b.state.busyIds.contains(booking.id), // true if busy
    );

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: _marginV,
      ), // margin
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radius),
      ), // shape
      elevation: 1.5, // light elevation
      child: Padding(
        padding: const EdgeInsets.all(_pad), // padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // align start
          children: [
            // ===== Header row =====
            Row(
              crossAxisAlignment: CrossAxisAlignment.start, // align start
              children: [
                // item image
                ClipRRect(
                  borderRadius: BorderRadius.circular(_radius), // radius
                  child: SizedBox(
                    width: _img, // width
                    height: _img, // height
                    child: _buildImage(booking.imageUrl), // image widget
                  ),
                ),
                const SizedBox(width: _gap), // gap
                // right info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // align start
                    children: [
                      // title
                      Text(
                        booking.itemName ??
                            l10n.activitiesNoActivities, // title text
                        maxLines: 1, // one line
                        overflow: TextOverflow.ellipsis, // ellipsis
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: _fsTitle, // small
                          height: _lhTight, // tight
                          letterSpacing: _lsTight, // spacing
                          fontWeight: FontWeight.w700, // bold
                          color: theme.colorScheme.primary, // primary color
                        ),
                      ),
                      const SizedBox(height: _gapSm), // gap
                      // booked by row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center, // center
                        children: [
                          // avatar
                          CircleAvatar(
                            radius: _avatar, // small
                            backgroundImage: booking.bookedByAvatar != null
                                ? NetworkImage(booking.bookedByAvatar!) // image
                                : null, // none
                            child: booking.bookedByAvatar == null
                                ? const Icon(
                                    Icons.person,
                                    size: 14,
                                  ) // placeholder
                                : null, // none
                          ),
                          const SizedBox(width: _gap), // gap
                          // label + name
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  flex: 0, // fit content
                                  child: Text(
                                    "${l10n.bookingsByUser} ", // label
                                    maxLines: 1, // one line
                                    overflow: TextOverflow.ellipsis, // ellipsis
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontSize: _fsUnified, // size
                                      height: _lhTight, // height
                                      letterSpacing: _lsTight, // spacing
                                      color: theme
                                          .colorScheme
                                          .onSurfaceVariant, // muted
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    booking.bookedBy ?? '-', // name
                                    maxLines: 1, // one line
                                    overflow: TextOverflow.ellipsis, // ellipsis
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontSize: _fsUnified, // size
                                      height: _lhTight, // height
                                      letterSpacing: _lsTight, // spacing
                                      fontWeight: FontWeight.w600, // semi bold
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: _gapSm), // gap
                      // status + paid + method chips
                      Wrap(
                        spacing: _gapSm, // gap
                        runSpacing: _gapSm, // wrap gap
                        children: [
                          // status chip uses color by normalized key
                          _chip(
                            context,
                            text: booking.status, // show original text
                            bg: _statusColor(key), // color by key
                            fg: Colors.white, // white text
                            bold: true, // bold
                          ),
                          if (booking.wasPaid) // paid chip
                            _chip(
                              context,
                              text: l10n.bookingsPaid, // paid
                              bg: theme.colorScheme.primaryContainer, // bg
                              fg: theme.colorScheme.onPrimaryContainer, // fg
                              bold: true, // bold
                            ),
                          _methodChip(
                            context,
                            booking.paymentMethod,
                          ), // method chip
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: _gap), // gap
            // ===== details panel =====
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(
                  0.25,
                ), // soft bg
                borderRadius: BorderRadius.circular(_radius), // radius
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 6,
              ), // pad
              child: Column(
                children: [
                  if ((booking.eventDateFormatted ?? '').isNotEmpty) // has date
                    _infoRow(
                      context: context, // ctx
                      icon: Icons.event, // icon
                      value: booking.eventDateFormatted!, // value
                    ),
                  if ((booking.itemLocation ?? '').isNotEmpty) ...[
                    const SizedBox(height: _gap), // gap
                    _infoRow(
                      context: context, // ctx
                      icon: Icons.place_rounded, // icon
                      label: l10n.bookingLocation, // label
                      value: booking.itemLocation!, // value
                    ),
                  ],
                  const SizedBox(height: _gap), // gap
                  _infoRow(
                    context: context, // ctx
                    icon: Icons.group_rounded, // icon
                    label: l10n.bookingParticipants, // label
                    value: booking.participants.toString(), // value
                  ),
                  const SizedBox(height: _gap), // gap
                  _infoRow(
                    context: context, // ctx
                    icon: Icons.payments_rounded, // icon
                    label: l10n.bookingPaymentMethod, // label
                    value: booking.paymentMethod, // value
                  ),
                  const SizedBox(height: _gap), // gap
                  _infoRow(
                    context: context, // ctx
                    icon: Icons.attach_money_rounded, // icon
                    label: l10n.bookingTotalPrice, // label
                    value: booking.totalFormatted, // value
                  ),
                ],
              ),
            ),

            const SizedBox(height: _gap), // gap
            // ===== actions row =====
            AbsorbPointer(
              absorbing: isBusy, // disable while busy
              child: Opacity(
                opacity: isBusy ? 0.6 : 1.0, // fade while busy
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end, // right align
                  children: [
                    // pending → Reject
                    if (key == 'pending') // normalized check
                      AppButton(
                        label: l10n.bookingReject, // label
                        onPressed: () async {
                          // confirm
                          final ok = await _confirmDialog(
                            context: context, // ctx
                            title: l10n.bookingConfirmRejectTitle, // title
                            message: l10n.bookingConfirmRejectMessage, // msg
                            confirmLabel: l10n.bookingConfirm_reject, // ok
                          );
                          if (ok) {
                            // fire event
                            context.read<BusinessBookingBloc>().add(
                              RejectBooking(booking.id), // event
                            );
                          }
                        },
                        type: AppButtonType.outline, // style
                        size: AppButtonSize.sm, // size
                      ),

                    // rejected → Unreject (back to pending)
                    if (key == 'rejected') ...[
                      const SizedBox(width: _gapSm), // gap
                      AppButton(
                        label: l10n.bookingUnreject, // label
                        onPressed: () async {
                          // confirm
                          final ok = await _confirmDialog(
                            context: context, // ctx
                            title: l10n.bookingConfirmUnrejectTitle, // title
                            message: l10n.bookingConfirmUnrejectMessage, // msg
                            confirmLabel: l10n.bookingConfirm_unreject, // ok
                          );
                          if (ok) {
                            // fire event
                            context.read<BusinessBookingBloc>().add(
                              UnrejectBooking(booking.id), // event
                            );
                          }
                        },
                        type: AppButtonType.text, // style
                        size: AppButtonSize.sm, // size
                      ),
                    ],

                    // ✅ FIX: CancelRequested → show Approve + Reject
                    if (key == 'cancelrequested') ...[
                      const SizedBox(width: _gapSm), // gap
                      AppButton(
                        label:
                            l10n.bookingConfirm_approveCancel, // Approve cancel
                        onPressed: () async {
                          // confirm
                          final ok = await _confirmDialog(
                            context: context, // ctx
                            title: l10n.bookingConfirm_approveCancel, // title
                            message: l10n.bookingMessage_approveCancel, // msg
                            confirmLabel: l10n.bookingApprove, // ok
                          );
                          if (ok) {
                            // fire approve
                            context.read<BusinessBookingBloc>().add(
                              ApproveCancelBooking(booking.id), // event
                            );
                          }
                        },
                        type: AppButtonType.secondary, // style
                        size: AppButtonSize.sm, // size
                      ),
                      const SizedBox(width: _gapSm), // gap
                      AppButton(
                        label: l10n.bookingRejectCancel, // Reject cancel
                        onPressed: () async {
                          // confirm
                          final ok = await _confirmDialog(
                            context: context, // ctx
                            title: l10n.bookingConfirm_rejectCancel, // title
                            message: l10n.bookingMessage_rejectCancel, // msg
                            confirmLabel: l10n.bookingConfirm_reject, // ok
                          );
                          if (ok) {
                            // fire reject
                            context.read<BusinessBookingBloc>().add(
                              RejectCancelBooking(booking.id), // event
                            );
                          }
                        },
                        type: AppButtonType.outline, // style
                        size: AppButtonSize.sm, // size
                      ),
                    ],

                    // mark paid if not paid
                    if (!booking.wasPaid) ...[
                      const SizedBox(width: _gapSm), // gap
                      AppButton(
                        label: l10n.bookingsMarkPaid, // label
                        onPressed: () async {
                          // confirm
                          final ok = await _confirmDialog(
                            context: context, // ctx
                            title: l10n.bookingsPaid, // title
                            message: l10n.bookingProcessing, // msg
                            confirmLabel: l10n.bookingApprove, // ok
                          );
                          if (ok) {
                            // fire mark paid
                            context.read<BusinessBookingBloc>().add(
                              MarkPaidBooking(booking.id), // event
                            );
                          }
                        },
                        type: AppButtonType.secondary, // style
                        size: AppButtonSize.sm, // size
                      ),
                    ],

                    // tiny spinner while busy
                    if (isBusy) ...[
                      const SizedBox(width: _gap), // gap
                      const SizedBox(
                        width: 12, // w
                        height: 12, // h
                        child: CircularProgressIndicator(
                          strokeWidth: 1.8,
                        ), // spinner
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
