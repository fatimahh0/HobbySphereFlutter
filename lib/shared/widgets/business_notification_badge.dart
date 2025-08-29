// Flutter 3.35.x
import 'dart:async'; // for Timer and Stream
import 'package:flutter/material.dart'; // UI widgets
import 'package:hobby_sphere/features/activities/data/services/business/business_notification_service.dart';
import 'package:hobby_sphere/shared/utils/notification_bus.dart';

class BusinessNotificationBadge extends StatefulWidget {
  // JWT token passed from your state (e.g., Provider/Redux)
  final String? token; // can be null before login
  // optional icon size (RN used ~26)
  final double iconSize; // default size

  const BusinessNotificationBadge({
    super.key, // widget key
    required this.token, // bearer token
    this.iconSize = 26, // default icon size
  });

  @override
  State<BusinessNotificationBadge> createState() =>
      _BusinessNotificationBadgeState();
}

class _BusinessNotificationBadgeState extends State<BusinessNotificationBadge> {
  // unread count shown in the red badge
  int _count = 0; // start with 0
  // periodic timer for auto refresh
  Timer? _ticker; // will run every 10s
  // prevent overlapping calls
  bool _busy = false; // simple lock

  // create one service instance (reuses global Dio inside ApiFetch)
  final _service = BusinessNotificationService(); // backend calls

  // fetch unread count from backend
  Future<void> _fetchCount() async {
    // skip if no token or if a request is already running
    if (widget.token == null || widget.token!.isEmpty || _busy) return; // guard
    _busy = true; // lock to avoid overlap
    try {
      // hit GET /api/notifications/business/unread-count
      final n = await _service.getBusinessUnreadNotificationCount(
        widget.token!,
      ); // backend call
      if (!mounted) return; // widget disposed? stop
      setState(() => _count = n); // update UI
    } catch (_) {
      // keep silent like RN console.warn to avoid UX noise
    } finally {
      _busy = false; // release lock
    }
  }

  @override
  void initState() {
    super.initState(); // call parent
    _fetchCount(); // initial load once
    _ticker = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _fetchCount(),
    ); // auto refresh every 10s
    // listen to manual refresh events (RN: notificationEventEmitter.on(...))
    NotificationBus.instance.refreshBusinessNotifications.stream.listen(
      (_) => _fetchCount(),
    ); // trigger
  }

  @override
  void didUpdateWidget(covariant BusinessNotificationBadge oldWidget) {
    super.didUpdateWidget(oldWidget); // call parent
    // if token changed (login/logout), refresh immediately
    if (oldWidget.token != widget.token) _fetchCount(); // re-fetch
  }

  @override
  void dispose() {
    // stop timer to avoid memory leaks
    _ticker?.cancel(); // cancel periodic job
    super.dispose(); // call parent
  }

  @override
  Widget build(BuildContext context) {
    // use Material 3 color scheme (respects light/dark theme)
    final scheme = Theme.of(context).colorScheme; // theme colors

    return Padding(
      padding: const EdgeInsets.all(6), // like RN: small padding around icon
      child: Stack(
        clipBehavior: Clip.none, // allow badge to overflow slightly
        children: [
          // bell icon (Material equivalent to Ionicons notifications-outline)
          Icon(
            Icons.notifications_none_outlined, // outlined bell
            size: widget.iconSize, // icon size
            color: scheme.primary, // primary color
          ),

          // show red badge only when count > 0
          if (_count > 0)
            Positioned(
              right: -2, // small right offset (match RN)
              top: -3, // small top offset (match RN)
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                ), // horizontal padding
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ), // min badge size
                decoration: BoxDecoration(
                  color: scheme.error, // red background from theme
                  borderRadius: BorderRadius.circular(10), // rounded pill
                ),
                alignment: Alignment.center, // center number
                child: Text(
                  '$_count', // unread count text
                  style:
                      Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme
                            .onError, // contrasting text color (usually white)
                        fontWeight: FontWeight.bold, // bold like RN
                      ) ??
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ), // fallback
                ),
              ),
            ),
        ],
      ),
    );
  }
}
