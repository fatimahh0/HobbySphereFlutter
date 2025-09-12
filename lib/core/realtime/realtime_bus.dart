// Flutter 3.35.x
// Broadcast stream so all BLoCs can listen to realtime events.

import 'dart:async'; // StreamController
import 'event_models.dart'; // RealtimeEvent model

class RealtimeBus {
  RealtimeBus._(); // private constructor
  static final RealtimeBus I = RealtimeBus._(); // singleton instance

  final _ctrl = StreamController<RealtimeEvent>.broadcast(); // broadcast stream

  Stream<RealtimeEvent> get stream => _ctrl.stream; // public stream to listen
  void emit(RealtimeEvent e) => _ctrl.add(e); // push event to all listeners
  void dispose() => _ctrl.close(); // close on app shutdown
}
