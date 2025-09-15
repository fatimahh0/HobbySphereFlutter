// Flutter 3.35.x
// Reusable notification bell with a numeric badge (theme-aware).

import 'package:flutter/material.dart'; // base Flutter UI

class NotificationBadge extends StatelessWidget {
  final int count; // unread number (0 => hide badge)
  final VoidCallback? onTap; // action when bell tapped
  final String? tooltip; // text on long-press/hover (optional)

  final IconData icon; // bell icon (customizable)
  final double iconSize; // bell size (default 26)

  final Color? bellColor; // custom bell color (null => cs.primary)
  final Color? badgeColor; // custom badge bg (null => cs.error)
  final Color? badgeTextColor; // custom badge text (null => cs.onError)

  final EdgeInsets padding; // outer padding of the control
  final double badgeRight; // badge X offset relative to bell
  final double badgeTop; // badge Y offset relative to bell

  const NotificationBadge({
    super.key,
    required this.count, // we need the count
    this.onTap, // optional tap
    this.tooltip, // optional tooltip
    this.icon = Icons.notifications_none_outlined, // default outlined bell
    this.iconSize = 26, // default size
    this.bellColor, // optional override
    this.badgeColor, // optional override
    this.badgeTextColor, // optional override
    this.padding = const EdgeInsets.all(6), // keep breathing space
    this.badgeRight = -2, // default position X
    this.badgeTop = -3, // default position Y
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme; // read theme's ColorScheme

    final bell = bellColor ?? cs.primary; // bell uses brand primary
    final bBg = badgeColor ?? cs.error; // badge bg uses error color
    final bFg = badgeTextColor ?? cs.onError; // badge text uses onError

    return Padding(
      padding: padding, // outer padding
      child: Stack(
        clipBehavior: Clip.none, // allow badge to overflow
        children: [
          IconButton(
            icon: Icon(icon, size: iconSize, color: bell), // the bell icon
            onPressed: onTap, // tap callback
            tooltip: tooltip ?? 'Notifications', // safe tooltip text
          ),
          if (count > 0) // show badge only if needed
            Positioned(
              right: badgeRight, // badge X offset
              top: badgeTop, // badge Y offset
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                ), // pill padding
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ), // min size
                decoration: BoxDecoration(
                  color: bBg, // badge background color
                  borderRadius: BorderRadius.circular(10), // pill shape
                ),
                alignment: Alignment.center, // center the text
                child: Text(
                  count > 99 ? '99+' : '$count', // cap big numbers
                  style:
                      Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: bFg, // readable on bg
                        fontWeight: FontWeight.bold, // stronger weight
                      ) ??
                      TextStyle(
                        color: bFg, // fallback style
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
