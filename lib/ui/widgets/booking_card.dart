// ===== Flutter 3.35.x =====
// booking_card.dart — Business-side booking card (no records, no static access)

import 'package:flutter/material.dart'; // UI widgets
import 'package:intl/intl.dart'; // format date/time
import 'package:hobby_sphere/l10n/app_localizations.dart' // L10n strings
    show AppLocalizations;
import 'package:hobby_sphere/core/network/globals.dart' // read serverRoot set in main()
    as g;

// Use Map for easy drop-in with your current JSON shape.
typedef Json = Map<String, dynamic>;

/// Small class to carry status style (instead of record type)
class _StatusStyle {
  final Color bg; // background color
  final Color fg; // text color
  final String label; // chip label
  const _StatusStyle({required this.bg, required this.fg, required this.label});
}

/// Small class to carry confirm dialog texts (title + message)
class _ConfirmTexts {
  final String title; // dialog title
  final String message; // dialog message
  const _ConfirmTexts(this.title, this.message);
}

// Presentational Booking Card (Business side)
class BookingCard extends StatelessWidget {
  // Full booking object from backend
  final Json booking;

  // Optional callbacks for actions
  final VoidCallback? onApproveCancel; // approve cancel request
  final VoidCallback? onRejectCancel; // reject cancel request
  final VoidCallback? onReject; // reject booking
  final VoidCallback? onUnreject; // unreject booking

  const BookingCard({
    super.key, // widget key
    required this.booking, // booking data
    this.onApproveCancel, // actions
    this.onRejectCancel,
    this.onReject,
    this.onUnreject,
  });

  // Build absolute URL for images (keeps http links, prefixes relative with serverRoot)
  String _fullUrl(String? raw) {
    if (raw == null || raw.isEmpty) return ''; // empty → empty
    if (raw.startsWith('http')) return raw; // absolute → keep
    final base =
        (g.appServerRoot ?? '') // read serverRoot set in main()
            .replaceAll(RegExp(r'/$'), ''); // strip trailing slash
    if (base.isEmpty) return raw; // if not set, return as-is (avoid crash)
    final path = raw.startsWith('/')
        ? raw
        : '/$raw'; // ensure single leading slash
    return '$base$path'; // join
  }

  // Map booking status → chip colors and label text
  _StatusStyle _statusStyle(BuildContext ctx, String status) {
    final scheme = Theme.of(ctx).colorScheme; // theme colors
    final t = AppLocalizations.of(ctx)!; // i18n strings

    switch (status) {
      case 'pending':
        return _StatusStyle(
          bg: const Color(0xFFFFEC9D), // soft yellow
          fg: Colors.black, // black text
          label: t.bookingsFiltersPending, // "Pending"
        );
      case 'completed':
        return _StatusStyle(
          bg: scheme.primary, // primary bg
          fg: scheme.onPrimary, // onPrimary text
          label: t.bookingsFiltersCompleted, // "Completed"
        );
      case 'canceled':
        return _StatusStyle(
          bg: scheme.error, // error bg
          fg: Colors.white, // white text
          label: t.bookingsFiltersCanceled, // "Canceled"
        );
      case 'rejected':
        return const _StatusStyle(
          bg: Color(0xFF6B7280), // gray bg
          fg: Colors.white, // white text
          label: 'Rejected', // fallback (or add key)
        );
      case 'cancelrequested':
        return const _StatusStyle(
          bg: Color(0xFFF59E0B), // amber
          fg: Colors.white,
          label: 'Cancel Requested', // fallback text
        );
      case 'cancelrejected':
        return const _StatusStyle(
          bg: Color(0xFF6B7280), // gray
          fg: Colors.white,
          label: 'Cancel Rejected', // fallback text
        );
      default:
        return _StatusStyle(
          bg: const Color(0xFFE5E7EB), // light gray
          fg: Colors.black,
          label:
              booking['bookingStatus']?.toString() ?? '—', // show raw/unknown
        );
    }
  }

  // Confirm dialog title/message from action name using your L10n keys
  _ConfirmTexts _confirmTexts(BuildContext ctx, String action) {
    final t = AppLocalizations.of(ctx)!; // i18n strings
    switch (action) {
      case 'approveCancel':
        return _ConfirmTexts(
          t.bookingConfirm_approveCancel,
          t.bookingMessage_approveCancel,
        );
      case 'rejectCancel':
        return _ConfirmTexts(
          t.bookingConfirm_rejectCancel,
          t.bookingMessage_rejectCancel,
        );
      case 'reject':
        return _ConfirmTexts(t.bookingConfirm_reject, t.bookingMessage_reject);
      case 'unreject':
        return _ConfirmTexts(
          t.bookingConfirm_unreject,
          t.bookingMessage_unreject,
        );
      default:
        return _ConfirmTexts(t.commonConfirm, t.commonAreYouSure);
    }
  }

  // Small rounded pill button (like RN <Pill/>)
  Widget _pill({
    required BuildContext context, // for theme
    required String title, // label
    required VoidCallback onTap, // action
    required Color bg, // background color
  }) {
    final textStyle = Theme.of(context).textTheme.labelLarge; // base style
    return Padding(
      padding: const EdgeInsets.only(right: 8, top: 8), // spacing
      child: InkWell(
        onTap: onTap, // tap handler
        borderRadius: BorderRadius.circular(999), // full pill
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 6,
            horizontal: 12,
          ), // inner padding
          decoration: BoxDecoration(
            color: bg, // bg color
            borderRadius: BorderRadius.circular(999), // full pill
          ),
          child: Text(
            title, // text
            style: (textStyle ?? const TextStyle()).copyWith(
              color: Colors.white, // white text
              fontWeight: FontWeight.bold, // bold
              fontSize: 13, // small
            ),
          ),
        ),
      ),
    );
  }

  // Show confirm dialog then call action if user confirms
  Future<void> _openConfirm(
    BuildContext context,
    String action,
    VoidCallback? cb,
  ) async {
    if (cb == null) return; // no-op if null

    final txt = _confirmTexts(context, action); // get title/message

    final ok = await showDialog<bool>(
      // show dialog
      context: context,
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme; // colors
        final t = AppLocalizations.of(ctx)!; // strings
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // rounded
          ),
          title: Text(txt.title, textAlign: TextAlign.center),
          content: Text(txt.message, textAlign: TextAlign.center),
          actionsAlignment: MainAxisAlignment.spaceEvenly, // center actions
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false), // cancel
              child: Text(
                t.buttonsCancel,
                style: TextStyle(color: scheme.primary),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true), // confirm
              child: Text(
                t.buttonsConfirm,
                style: TextStyle(color: scheme.primary),
              ),
            ),
          ],
        );
      },
    );

    if (ok == true) cb(); // run if confirmed
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // theme
    final scheme = theme.colorScheme; // colors
    final t = AppLocalizations.of(context)!; // strings

    // Extract nested objects safely
    final Json item = (booking['item'] as Json?) ?? {}; // item info
    final Json user = (booking['user'] as Json?) ?? {}; // user info

    // Resolve images (absolute or server-root + relative)
    final itemImg = _fullUrl(item['imageUrl']?.toString()); // item image
    final avatarImg = _fullUrl(user['profilePictureUrl']?.toString()); // avatar

    // Normalize status (lowercase)
    final status = (booking['bookingStatus']?.toString() ?? '').toLowerCase();
    final st = _statusStyle(context, status); // chip style

    // Parse booking datetime safely (no pattern matching)
    DateTime? dt; // date holder
    final rawDt = booking['bookingDatetime']; // raw value
    if (rawDt is String) {
      // ISO string
      dt = DateTime.tryParse(rawDt);
    } else if (rawDt is num) {
      // unix ms
      dt = DateTime.fromMillisecondsSinceEpoch(rawDt.toInt());
    }

    // Format date/time or show —
    final dateText = dt != null ? DateFormat.yMd().format(dt) : '—';
    final timeText = dt != null ? DateFormat.Hm().format(dt) : '—';

    // Text values with fallbacks
    final bookedBy =
        booking['bookedByName']?.toString() ??
        user['username']?.toString() ??
        '-'; // who
    final itemName = item['itemName']?.toString() ?? '-'; // title
    final participants = booking['numberOfParticipants'] ?? 0; // count
    final cancelReason = booking['cancelReason']?.toString(); // reason (opt)

    // Total price formatting (no pattern matching)
    final total = booking['totalPrice']; // raw total
    String totalText;
    if (total is num) {
      totalText = total.toStringAsFixed(2); // 2 decimals
    } else if (total is String) {
      totalText = total; // already string
    } else {
      totalText = '--'; // unknown
    }

    // Card UI
    return Material(
      color: Colors.transparent, // no bg
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surface, // card bg
          borderRadius: BorderRadius.circular(16), // rounded
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06), // soft shadow
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias, // clip corners
        child: SizedBox(
          height: 140, // fixed height
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch, // image fills
            children: [
              // Left: item image
              AspectRatio(
                aspectRatio: 1, // square
                child: itemImg.isNotEmpty
                    ? Image.network(
                        itemImg, // url
                        fit: BoxFit.cover, // cover
                        errorBuilder: (_, __, ___) => const _ImagePlaceholder(),
                        loadingBuilder: (ctx, child, progress) {
                          if (progress == null) return child; // loaded
                          return const _ImageLoading(); // loading box
                        },
                      )
                    : const _ImagePlaceholder(), // no image
              ),

              // Right: content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12), // inner space
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row: avatar + name + date
                      Row(
                        children: [
                          // Avatar (circle)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: SizedBox(
                              width: 32,
                              height: 32, // size
                              child: avatarImg.isNotEmpty
                                  ? Image.network(
                                      avatarImg, // url
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const _AvatarFallback(),
                                    )
                                  : const _AvatarFallback(),
                            ),
                          ),
                          const SizedBox(width: 8), // space
                          // Name + DT
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bookedBy, // who
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: scheme.onSurface,
                                ),
                              ),
                              Text(
                                '$dateText · $timeText', // date · time
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 6), // small gap
                      // Item title (primary color)
                      Text(
                        itemName, // title
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.primary,
                        ),
                      ),

                      // Meta: participants
                      Text(
                        '${t.bookingParticipants}: $participants',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurface.withOpacity(0.7),
                        ),
                      ),

                      // Meta: total price
                      Text(
                        '${t.bookingTotal}: \$${totalText}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurface.withOpacity(0.7),
                        ),
                      ),

                      // Optional: cancel reason
                      if (cancelReason != null && cancelReason.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            '${t.bookingCancelReason}: $cancelReason',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ),

                      const Spacer(), // push bottom row
                      // Bottom: status chip + action pills
                      Row(
                        children: [
                          // Status chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 10,
                            ),
                            decoration: BoxDecoration(
                              color: st.bg, // bg
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              st.label, // text
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: st.fg, // fg
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const Spacer(), // push actions
                          // Actions logic
                          if (status == 'cancelrequested' &&
                              onApproveCancel != null)
                            _pill(
                              context: context,
                              title: t.bookingApprove, // "Approve"
                              onTap: () => _openConfirm(
                                context,
                                'approveCancel',
                                onApproveCancel,
                              ),
                              bg: scheme.primary,
                            ),
                          if (status == 'cancelrequested' &&
                              onRejectCancel != null)
                            _pill(
                              context: context,
                              title: t
                                  .bookingRejectCancel, // "Reject Cancellation"
                              onTap: () => _openConfirm(
                                context,
                                'rejectCancel',
                                onRejectCancel,
                              ),
                              bg: scheme.error,
                            ),
                          if (status == 'pending' && onReject != null)
                            _pill(
                              context: context,
                              title: t.bookingReject, // "Reject"
                              onTap: () =>
                                  _openConfirm(context, 'reject', onReject),
                              bg: scheme.error,
                            ),
                          if (status == 'rejected' && onUnreject != null)
                            _pill(
                              context: context,
                              title: t.bookingUnreject, // "Unreject"
                              onTap: () =>
                                  _openConfirm(context, 'unreject', onUnreject),
                              bg: scheme.primary,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Simple gray placeholder when item image missing/fails
class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE5E7EB),
      child: const Center(child: Icon(Icons.image_not_supported_outlined)),
    );
  }
}

// Minimal loading placeholder (no animation to keep it simple)
class _ImageLoading extends StatelessWidget {
  const _ImageLoading();
  @override
  Widget build(BuildContext context) {
    return Container(color: const Color(0xFFF1F5F9));
  }
}

// Fallback avatar (square with person icon)
class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE5E7EB),
      child: const Icon(Icons.person, size: 18, color: Color(0xFF64748B)),
    );
  }
}
