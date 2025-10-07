// lib/features/activities/user/userCommunity/presentation/cubits/unread_cubit.dart
// Flutter 3.35.x — Unread count with realtime auto-refresh

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/features/activities/user/userCommunity/domain/usecases/get_unread_notifications.dart';

// 👇 add these imports
import 'package:hobby_sphere/core/realtime/realtime_bus.dart';
import 'package:hobby_sphere/core/realtime/event_models.dart';

class UnreadState {
  final int count;
  final bool loading;
  final String? error;
  const UnreadState({this.count = 0, this.loading = false, this.error});
  UnreadState copyWith({int? count, bool? loading, String? error}) =>
      UnreadState(
        count: count ?? this.count,
        loading: loading ?? this.loading,
        error: error,
      );
}

class UnreadCubit extends Cubit<UnreadState> {
  final GetUnreadNotifications getUnread;

  // 👇 keep last used token to refresh on incoming realtime events
  String? _lastToken;

  // 👇 realtime subscription
  StreamSubscription<RealtimeEvent>? _rt;

  UnreadCubit(this.getUnread, {bool enableRealtime = true, required Future<Map<int, int>> Function() loadAll})
    : super(const UnreadState()) {
    if (enableRealtime) {
      _rt = RealtimeBus.I.stream.listen((e) async {
        if (e.domain == Domain.notification) {
          // when any notification event arrives, refresh badge
          final t = _lastToken;
          if (t != null) {
            try {
              final c = await getUnread(t);
              emit(state.copyWith(count: c, loading: false, error: null));
            } catch (err) {
              // keep old count; only surface error if you want
              // emit(state.copyWith(error: err.toString()));
            }
          }
        }
      });
    }
  }

  Future<void> refresh(String token) async {
    _lastToken = token; // remember for realtime refreshes
    try {
      emit(state.copyWith(loading: true, error: null));
      final c = await getUnread(token);
      emit(state.copyWith(count: c, loading: false));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _rt?.cancel();
    return super.close();
  }
}
