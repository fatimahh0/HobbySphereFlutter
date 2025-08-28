// Flutter 3.35.x
import 'package:flutter/material.dart'; // UI widgets
import 'package:intl/intl.dart'; // format date/time
import 'package:hobby_sphere/l10n/app_localizations.dart'
    show AppLocalizations; // L10n strings
import 'package:hobby_sphere/core/network/api_config.dart'; // serverRoot from hostIp.json

// Use Map for easy drop-in with your current JSON shape (item/user/status...).
typedef Json = Map<String, dynamic>;

// Presentational Booking Card (Business side) – mirrors your RN component.
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
    // If empty, return empty
    if (raw == null || raw.isEmpty) return '';
    // If already absolute, keep it
    if (raw.startsWith('http')) return raw;
    // Else prefix with server root (no trailing slash)
    final base = ApiConfig.serverRoot.replaceAll(RegExp(r'/$'), '');
    final path = raw.startsWith('/') ? raw : '/$raw';
    return '$base$path';
  }

  // Map booking status → chip colors and label text (use your L10n keys when possible)
  ({Color bg, Color fg, String label}) _statusStyle(
    BuildContext ctx,
    String status,
  ) {
    // Access theme + i18n
    final scheme = Theme.of(ctx).colorScheme; // colors from theme
    final t = AppLocalizations.of(ctx)!; // translations

    // Match RN statuses
    switch (status) {
      case 'pending':
        // Use your "Pending" key
        return (
          bg: const Color(0xFFFFEC9D),
          fg: Colors.black,
          label: t.bookingsFiltersPending,
        );
      case 'completed':
        // Use your "Completed" key
        return (
          bg: scheme.primary,
          fg: scheme.onPrimary,
          label: t.bookingsFiltersCompleted,
        );
      case 'canceled':
        // Use your "Canceled" key
        return (
          bg: scheme.error,
          fg: Colors.white,
          label: t.bookingsFiltersCanceled,
        );
      case 'rejected':
        // Use your "Rejected" key
        return (
          bg: const Color(0xFF6B7280),
          fg: Colors.white,
          label: t.bookingsFiltersRejected,
        );
      case 'cancelrequested':
        // Not in your list → fallback readable text
        return (
          bg: const Color(0xFFF59E0B),
          fg: Colors.white,
          label: 'Cancel Requested',
        );
      case 'cancelrejected':
        // Not in your list → fallback readable text
        return (
          bg: const Color(0xFF6B7280),
          fg: Colors.white,
          label: 'Cancel Rejected',
        );
      default:
        // Unknown → show raw status
        return (
          bg: const Color(0xFFE5E7EB),
          fg: Colors.black,
          label: booking['bookingStatus']?.toString() ?? '—',
        );
    }
  }

  // Confirm dialog title/message from action name using your L10n keys
  (String title, String message) _confirmTexts(
    BuildContext ctx,
    String action,
  ) {
    // Access translations
    final t = AppLocalizations.of(ctx)!;

    // Map action → title/message keys (exactly like your RN names)
    switch (action) {
      case 'approveCancel':
        return (t.bookingConfirm_approveCancel, t.bookingMessage_approveCancel);
      case 'rejectCancel':
        return (t.bookingConfirm_rejectCancel, t.bookingMessage_rejectCancel);
      case 'reject':
        return (t.bookingConfirm_reject, t.bookingMessage_reject);
      case 'unreject':
        return (t.bookingConfirm_unreject, t.bookingMessage_unreject);
      default:
        return (t.commonConfirm, t.commonAreYouSure);
    }
  }

  // Small rounded pill button (like RN <Pill/>)
  Widget _pill({
    required BuildContext context, // for theme
    required String title, // button label
    required VoidCallback onTap, // action
    required Color bg, // background color
  }) {
    // Use theme text styles
    final textStyle = Theme.of(context).textTheme.labelLarge;

    // Return rounded ink button
    return Padding(
      padding: const EdgeInsets.only(right: 8, top: 8), // small spacing
      child: InkWell(
        onTap: onTap, // handle tap
        borderRadius: BorderRadius.circular(999), // full pill
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 6,
            horizontal: 12,
          ), // pill padding
          decoration: BoxDecoration(
            color: bg, // background color
            borderRadius: BorderRadius.circular(999), // full pill
          ),
          child: Text(
            title, // text
            style: (textStyle ?? const TextStyle()).copyWith(
              color: Colors.white, // white text
              fontWeight: FontWeight.bold, // bold text
              fontSize: 13, // small size
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
    // If no callback, do nothing
    if (cb == null) return;

    // Prepare localized title/message
    final (title, message) = _confirmTexts(context, action);

    // Show material confirm dialog
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        // Access theme + i18n inside dialog
        final scheme = Theme.of(ctx).colorScheme;
        final t = AppLocalizations.of(ctx)!;

        // Build dialog UI
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ), // rounded corners
          title: Text(title, textAlign: TextAlign.center), // dialog title
          content: Text(message, textAlign: TextAlign.center), // dialog message
          actionsAlignment: MainAxisAlignment.spaceEvenly, // centered actions
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false), // cancel -> false
              child: Text(
                t.buttonsCancel,
                style: TextStyle(color: scheme.primary),
              ), // cancel text
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true), // confirm -> true
              child: Text(
                t.buttonsConfirm,
                style: TextStyle(color: scheme.primary),
              ), // confirm text
            ),
          ],
        );
      },
    );

    // If confirmed, run callback
    if (ok == true) cb();
  }

  @override
  Widget build(BuildContext context) {
    // Access theme + i18n
    final theme = Theme.of(context); // theme
    final scheme = theme.colorScheme; // colors
    final t = AppLocalizations.of(context)!; // strings

    // Extract nested objects (like RN)
    final Json item = (booking['item'] as Json?) ?? {}; // item info
    final Json user = (booking['user'] as Json?) ?? {}; // user info

    // Resolve images (absolute or server-root + relative)
    final itemImg = _fullUrl(item['imageUrl']?.toString()); // item image
    final avatarImg = _fullUrl(
      user['profilePictureUrl']?.toString(),
    ); // user avatar

    // Normalize status (lowercase)
    final status = (booking['bookingStatus']?.toString() ?? '')
        .toLowerCase(); // status
    // Chip style for status
    final st = _statusStyle(context, status); // (bg, fg, label)

    // Parse booking datetime safely
    final DateTime? dt = switch (booking['bookingDatetime']) {
      null => null, // none
      final s when s is String => DateTime.tryParse(s), // ISO string
      final n when n is num => DateTime.fromMillisecondsSinceEpoch(
        n.toInt(),
      ), // unix ms
      _ => null, // other
    };

    // Format date/time (or show —)
    final dateText = dt != null ? DateFormat.yMd().format(dt) : '—'; // date
    final timeText = dt != null ? DateFormat.Hm().format(dt) : '—'; // time

    // Text values with fallbacks
    final bookedBy =
        booking['bookedByName']?.toString() ??
        user['username']?.toString() ??
        '-'; // who
    final itemName = item['itemName']?.toString() ?? '-'; // item title
    final participants = booking['numberOfParticipants'] ?? 0; // count
    final cancelReason = booking['cancelReason']
        ?.toString(); // reason (optional)

    // Total price formatting
    final total = booking['totalPrice']; // total raw
    final totalText = switch (total) {
      final n when n is num => n.toStringAsFixed(2), // 2 decimals
      final s when s is String => s, // already string
      _ => '--', // unknown
    };

    // Card UI
    return Material(
      // material surface for ripple/shadows
      color: Colors.transparent, // no background
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surface, // card background from theme
          borderRadius: BorderRadius.circular(16), // rounded corners
          boxShadow: [
            BoxShadow(
              // soft shadow
              color: Colors.black.withOpacity(0.06), // subtle
              blurRadius: 12, // blur
              offset: const Offset(0, 6), // drop
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias, // clip children to radius
        child: SizedBox(
          height: 140, // card height (like RN row)
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.stretch, // image fills height
            children: [
              // Left: item image
              AspectRatio(
                aspectRatio: 1, // square
                child: itemImg.isNotEmpty
                    ? Image.network(
                        itemImg, // url
                        fit: BoxFit.cover, // cover
                        errorBuilder: (_, __, ___) =>
                            const _ImagePlaceholder(), // if error
                        loadingBuilder: (ctx, child, progress) {
                          if (progress == null) return child; // loaded
                          return const _ImageLoading(); // loading box
                        },
                      )
                    : const _ImagePlaceholder(), // empty → placeholder
              ),

              // Right: content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12), // inner spacing
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // left align
                    children: [
                      // Row: avatar + name + date
                      Row(
                        children: [
                          // Avatar (circle)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              20,
                            ), // circle-ish
                            child: SizedBox(
                              width: 32,
                              height: 32, // size
                              child: avatarImg.isNotEmpty
                                  ? Image.network(
                                      avatarImg, // url
                                      fit: BoxFit.cover, // cover
                                      errorBuilder: (_, __, ___) =>
                                          const _AvatarFallback(), // if error
                                    )
                                  : const _AvatarFallback(), // empty → fallback
                            ),
                          ),
                          const SizedBox(width: 8), // space
                          // Name + DT
                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start, // left align
                            children: [
                              Text(
                                bookedBy, // who
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600, // semi-bold
                                  color: scheme.onSurface, // text color
                                ),
                              ),
                              Text(
                                '$dateText · $timeText', // date · time
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurface.withOpacity(
                                    0.6,
                                  ), // muted
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
                        maxLines: 1, // single line
                        overflow: TextOverflow.ellipsis, // clip
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold, // bold
                          color: scheme.primary, // primary color
                        ),
                      ),

                      // Meta: participants
                      Text(
                        '${t.bookingParticipants}: $participants', // localized label
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurface.withOpacity(0.7), // muted
                        ),
                      ),

                      // Meta: total price
                      Text(
                        '${t.bookingTotal}: \$${totalText}', // localized label
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurface.withOpacity(0.7), // muted
                        ),
                      ),

                      // Optional: cancel reason
                      if (cancelReason != null && cancelReason.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2), // tiny gap
                          child: Text(
                            '${t.bookingCancelReason}: $cancelReason', // label + reason
                            maxLines: 2, // clamp
                            overflow: TextOverflow.ellipsis, // ellipsis
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurface.withOpacity(0.7), // muted
                            ),
                          ),
                        ),

                      const Spacer(), // push chip + actions down
                      // Bottom: status chip + action pills
                      Row(
                        children: [
                          // Status chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 10,
                            ), // padding
                            decoration: BoxDecoration(
                              color: st.bg, // bg color
                              borderRadius: BorderRadius.circular(12), // round
                            ),
                            child: Text(
                              st.label, // chip text
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: st.fg, // fg color
                                fontWeight: FontWeight.bold, // bold
                              ),
                            ),
                          ),

                          const Spacer(), // push actions right
                          // Actions like RN logic
                          if (status == 'cancelrequested' &&
                              onApproveCancel != null)
                            _pill(
                              context: context,
                              title: t.bookingApprove, // "Approve"
                              onTap: () => _openConfirm(
                                context,
                                'approveCancel',
                                onApproveCancel,
                              ), // confirm then run
                              bg: scheme.primary, // primary color
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
                              ), // confirm then run
                              bg: scheme.error, // error color
                            ),
                          if (status == 'pending' && onReject != null)
                            _pill(
                              context: context,
                              title: t.bookingReject, // "Reject"
                              onTap: () => _openConfirm(
                                context,
                                'reject',
                                onReject,
                              ), // confirm then run
                              bg: scheme.error, // error color
                            ),
                          if (status == 'rejected' && onUnreject != null)
                            _pill(
                              context: context,
                              title: t.bookingUnreject, // "Unreject"
                              onTap: () => _openConfirm(
                                context,
                                'unreject',
                                onUnreject,
                              ), // confirm then run
                              bg: scheme.primary, // primary color
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
      color: const Color(0xFFE5E7EB), // light gray
      child: const Center(
        child: Icon(Icons.image_not_supported_outlined),
      ), // icon
    );
  }
}

// Minimal loading placeholder (no animation to keep it simple)
class _ImageLoading extends StatelessWidget {
  const _ImageLoading();

  @override
  Widget build(BuildContext context) {
    return Container(color: const Color(0xFFF1F5F9)); // lighter gray
  }
}

// Fallback avatar (circle with person icon)
class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE5E7EB), // gray
      child: const Icon(
        Icons.person,
        size: 18,
        color: Color(0xFF64748B),
      ), // muted icon
    );
  }
}
