import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/features/activities/user/userNotification/data/repositories/user_notification_repository_impl.dart';
import 'package:hobby_sphere/features/activities/user/userNotification/domain/usecases/get_user_notifications.dart';

import 'user_notification_event.dart';
import 'user_notification_state.dart';


import 'package:hobby_sphere/core/realtime/realtime_bus.dart';
import 'package:hobby_sphere/core/realtime/event_models.dart';

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
    on<LoadUserNotifications>((event, emit) async {
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
            error: null,
          ),
        );
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    });

    on<LoadUnreadCount>((event, emit) async {
      try {
        final count = await repository.getUnreadCount(token);
        emit(state.copyWith(unreadCount: count, error: null));
      } catch (e) {
        emit(state.copyWith(error: e.toString()));
      }
    });

    on<MarkUserNotificationRead>((event, emit) async {
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
    });

    on<DeleteUserNotification>((event, emit) async {
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
    });

    on<ClearError>((event, emit) {
      emit(state.copyWith(error: null));
    });

    if (enableRealtime) {
      _rtSub = RealtimeBus.I.stream.listen((e) {
        if (e.domain == Domain.notification) {
          add(LoadUserNotifications());
          add(LoadUnreadCount());
        }
      });
    }
  }

  @override
  Future<void> close() async {
    await _rtSub?.cancel();
    return super.close();
  }
}
