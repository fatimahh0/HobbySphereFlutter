// ===== Flutter 3.35.x =====
// Bloc for Business Notifications
// - Load notifications
// - Load unread count
// - Mark as read
// - Delete

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/businessNotification/domain/entities/business_notification.dart';
import 'package:hobby_sphere/features/activities/Business/businessNotification/domain/usecases/get_business_notifications.dart';
import 'package:hobby_sphere/features/activities/Business/businessNotification/presentation/bloc/business_notification_event.dart';
import 'package:hobby_sphere/features/activities/Business/businessNotification/presentation/bloc/business_notification_state.dart';
import 'package:hobby_sphere/features/activities/Business/businessNotification/data/repositories/business_notification_repository_impl.dart';

class BusinessNotificationBloc
    extends Bloc<BusinessNotificationEvent, BusinessNotificationState> {
  final GetBusinessNotifications getBusinessNotifications;
  final BusinessNotificationRepositoryImpl repository;
  final String token;

  BusinessNotificationBloc({
    required this.getBusinessNotifications,
    required this.repository,
    required this.token,
  }) : super(const BusinessNotificationState()) {
    // Load all notifications
    on<LoadBusinessNotifications>((event, emit) async {
      emit(state.copyWith(isLoading: true, error: null));
      try {
        final data = await getBusinessNotifications(token);
        final list = data
            .map((e) => e as BusinessNotification)
            .toList(growable: false);

        // compute unread count
        final unreadCount = list.where((n) => !n.read).length;

        emit(
          state.copyWith(
            notifications: list,
            isLoading: false,
            unreadCount: unreadCount,
          ),
        );
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    });

    // Load unread count only
    on<LoadUnreadCount>((event, emit) async {
      try {
        final count = await repository.getUnreadCount(event.token);
        emit(state.copyWith(unreadCount: count));
      } catch (e) {
        emit(state.copyWith(error: e.toString()));
      }
    });

    // Mark notification as read
    on<MarkBusinessNotificationRead>((event, emit) async {
      try {
        await repository.markAsRead(token, event.id);
        final updated = state.notifications.map((n) {
          if (n.id == event.id) {
            return n.copyWith(read: true);
          }
          return n;
        }).toList();

        final unreadCount = updated.where((n) => !n.read).length;

        emit(state.copyWith(notifications: updated, unreadCount: unreadCount));
      } catch (e) {
        emit(state.copyWith(error: e.toString()));
      }
    });

    // Delete notification
    on<DeleteBusinessNotification>((event, emit) async {
      try {
        await repository.deleteNotification(token, event.id);
        final updated = state.notifications
            .where((n) => n.id != event.id)
            .toList();

        final unreadCount = updated.where((n) => !n.read).length;

        emit(state.copyWith(notifications: updated, unreadCount: unreadCount));
      } catch (e) {
        emit(state.copyWith(error: e.toString()));
      }
    });
  }
}
