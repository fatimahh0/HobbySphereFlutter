// Flutter 3.35.x
// realtime_bus.dart — Broadcast bus so any screen can listen to realtime events.

import 'dart:async'; // StreamController, Stream
import 'event_models.dart'; // RealtimeEvent type

class RealtimeBus {
  RealtimeBus._(); // private constructor (singleton pattern)
  static final RealtimeBus I = RealtimeBus._(); // single shared instance

  final _ctrl = StreamController<RealtimeEvent>.broadcast(); // broadcast stream

  Stream<RealtimeEvent> get stream => _ctrl.stream; // output stream to listen
  void emit(RealtimeEvent e) => _ctrl.add(e); // push an event to listeners
  Future<void> dispose() => _ctrl.close(); // close when app shuts down
}
