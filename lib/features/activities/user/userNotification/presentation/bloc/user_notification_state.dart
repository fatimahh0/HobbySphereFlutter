import 'package:equatable/equatable.dart';
import 'package:hobby_sphere/features/activities/user/userNotification/domain/entities/user_notification.dart';

class UserNotificationState extends Equatable {
  final List<UserNotification> notifications;
  final bool isLoading;
  final String? error;
  final int unreadCount;

  const UserNotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
    this.unreadCount = 0,
  });

  UserNotificationState copyWith({
    List<UserNotification>? notifications,
    bool? isLoading,
    String? error,
    int? unreadCount,
  }) {
    return UserNotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  List<Object?> get props => [notifications, isLoading, error, unreadCount];
}
