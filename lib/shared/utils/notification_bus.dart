// Flutter 3.35.x
import 'dart:async'; // StreamController

// Simple event bus to mimic RN "notificationEventEmitter"
class NotificationBus {
  // singleton instance
  static final NotificationBus instance =
      NotificationBus._internal(); // one instance
  NotificationBus._internal(); // private constructor

  // broadcast stream for "refreshBusinessNotifications"
  final StreamController<void> refreshBusinessNotifications =
      StreamController<void>.broadcast(); // stream

  // dispose when app ends (optional)
  void dispose() {
    refreshBusinessNotifications.close(); // close stream
  }
}
