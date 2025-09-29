import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hobby_sphere/core/realtime/event_models.dart';
import 'package:hobby_sphere/core/realtime/realtime_bus.dart';

import 'package:hobby_sphere/features/activities/user/userNotification/data/repositories/user_notification_repository_impl.dart';
import 'package:hobby_sphere/features/activities/user/userNotification/domain/usecases/get_user_notifications.dart';

import 'user_notification_event.dart';
import 'user_notification_state.dart';

class UserNotificationBloc
    extends Bloc<UserNotificationEvent, UserNotificationState> {
  final GetUserNotifications getUserNotifications;
  final UserNotificationRepositoryImpl repository;
  final String token;

  StreamSubscription<RealtimeEvent>? _rtSub;

  UserNotificationBloc({
    required this.getUserNotifications,
    required this.repository,
    required this.token,
    bool enableRealtime = true,
  }) : super(const UserNotificationState()) {
    on<LoadUserNotifications>(_onLoadAll);
    on<LoadUnreadCount>(_onUnread);
    on<MarkUserNotificationRead>(_onMarkRead);
    on<DeleteUserNotification>(_onDelete);
    on<ClearError>((_, emit) => emit(state.copyWith(error: null)));

    // Realtime: whenever a notification event arrives, refresh both.
    if (enableRealtime) {
      _rtSub = RealtimeBus.I.stream.listen((e) {
        if (e.domain == Domain.notification) {
          add(LoadUserNotifications());
          add(LoadUnreadCount());
        }
      });
    }
  }

  Future<void> _onLoadAll(
    LoadUserNotifications event,
    Emitter<UserNotificationState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final data = await getUserNotifications(token);
      final list = data.toList(growable: false)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final unread = list.where((n) => !n.read).length;
      emit(
        state.copyWith(
          notifications: list,
          isLoading: false,
          unreadCount: unread,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onUnread(
    LoadUnreadCount event,
    Emitter<UserNotificationState> emit,
  ) async {
    try {
      final count = await repository.getUnreadCount(token);
      emit(state.copyWith(unreadCount: count, error: null));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onMarkRead(
    MarkUserNotificationRead event,
    Emitter<UserNotificationState> emit,
  ) async {
    try {
      await repository.markAsRead(token, event.id);
      final updated = state.notifications
          .map((n) => n.id == event.id ? n.copyWith(read: true) : n)
          .toList(growable: false);
      final unread = updated.where((n) => !n.read).length;
      emit(
        state.copyWith(
          notifications: updated,
          unreadCount: unread,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onDelete(
    DeleteUserNotification event,
    Emitter<UserNotificationState> emit,
  ) async {
    try {
      await repository.deleteNotification(token, event.id);
      final updated = state.notifications
          .where((n) => n.id != event.id)
          .toList(growable: false);
      final unread = updated.where((n) => !n.read).length;
      emit(
        state.copyWith(
          notifications: updated,
          unreadCount: unread,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _rtSub?.cancel();
    return super.close();
  }
}
