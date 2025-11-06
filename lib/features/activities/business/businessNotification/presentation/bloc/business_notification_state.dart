// ===== Flutter 3.35.x =====
// State for BusinessNotificationBloc

import 'package:equatable/equatable.dart';
import 'package:hobby_sphere/features/activities/Business/businessNotification/domain/entities/business_notification.dart';

class BusinessNotificationState extends Equatable {
  final List<BusinessNotification> notifications;
  final bool isLoading;
  final String? error;
  final int unreadCount;

  const BusinessNotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
    this.unreadCount = 0,
  });

  BusinessNotificationState copyWith({
    List<BusinessNotification>? notifications,
    bool? isLoading,
    String? error,
    int? unreadCount,
  }) {
    return BusinessNotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  List<Object?> get props => [notifications, isLoading, error, unreadCount];
}
