// ===== Flutter 3.35.x =====
// Events for BusinessNotificationBloc

import 'package:equatable/equatable.dart';

abstract class BusinessNotificationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Load all notifications
class LoadBusinessNotifications extends BusinessNotificationEvent {}

/// Mark notification as read
class MarkBusinessNotificationRead extends BusinessNotificationEvent {
  final int id;
  MarkBusinessNotificationRead(this.id);

  @override
  List<Object?> get props => [id];
}

/// Load unread notifications count
class LoadUnreadCount extends BusinessNotificationEvent {
  final String token;
  LoadUnreadCount(this.token);

  @override
  List<Object?> get props => [token];
}

/// Delete notification
class DeleteBusinessNotification extends BusinessNotificationEvent {
  final int id;
  DeleteBusinessNotification(this.id);

  @override
  List<Object?> get props => [id];
}
