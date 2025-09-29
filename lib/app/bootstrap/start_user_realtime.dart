// lib/core/realtime/user_realtime_boot.dart
// Flutter 3.35.x — Start/Stop the USER websocket and keep one bridge instance.

import 'package:hobby_sphere/core/realtime/realtime_service.dart'; // ws client
import 'package:hobby_sphere/core/realtime/user_realtime_bridge.dart'; // router
import 'package:hobby_sphere/core/network/globals.dart' as g; // token/base

// singletons (user side)
final userRealtimeService = RealtimeService(); // websocket client
final userBridge = UserRealtimeBridge(); // routes events to features

/// call after login (after you set g.appServerRoot and g.token)
Future<void> startUserRealtime() async {
  // connect to server — ensure base does NOT contain /api
  final httpBase = (g.appServerRoot ?? 'http://10.0.2.2:8080').replaceFirst(
    RegExp(r'/api/?$'),
    '',
  );
  userRealtimeService.connect(
    httpBase: httpBase, // backend root
    token: (g.token ?? '').trim(), // JWT (payload only)
  );
  userBridge.start(); // listen to bus
}

/// call on logout
Future<void> stopUserRealtime() async {
  await userBridge.stop(); // stop routing
  userRealtimeService.dispose(); // close socket + stop ping
}

/// call on token refresh (optional)
void refreshUserRealtimeToken(String newToken) {
  userRealtimeService.reconnectWithToken(newToken); // reopen with new JWT
}
