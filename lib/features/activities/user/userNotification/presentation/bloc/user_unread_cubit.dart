
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/core/realtime/event_models.dart';
import 'package:hobby_sphere/core/realtime/realtime_bus.dart';
import 'package:hobby_sphere/features/activities/user/userNotification/domain/repositories/user_notification_repository.dart';

class UserUnreadState {
  final int count;
  final bool loading;
  final String? error;

  const UserUnreadState({this.count = 0, this.loading = false, this.error});

  UserUnreadState copyWith({int? count, bool? loading, String? error}) {
    return UserUnreadState(
      count: count ?? this.count,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class UserUnreadNotificationsCubit extends Cubit<UserUnreadState> {
  final UserNotificationRepository repo;
  final String token;

  StreamSubscription<RealtimeEvent>? _rt;

  UserUnreadNotificationsCubit({
    required this.repo,
    required this.token,
    bool enableRealtime = true,
  }) : super(const UserUnreadState()) {
    if (enableRealtime) {
      _rt = RealtimeBus.I.stream.listen((e) {
        if (e.domain == Domain.notification) {
          refresh();
        }
      });
    }
  }

  Future<void> refresh() async {
    try {
      emit(state.copyWith(loading: true, error: null));
      final c = await repo.getUnreadCount(token);
      emit(state.copyWith(count: c, loading: false, error: null));
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
