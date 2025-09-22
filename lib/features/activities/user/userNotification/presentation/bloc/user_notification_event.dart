import 'package:equatable/equatable.dart';

abstract class UserNotificationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadUserNotifications extends UserNotificationEvent {}

class LoadUnreadCount extends UserNotificationEvent {}

class MarkUserNotificationRead extends UserNotificationEvent {
  final int id;
  MarkUserNotificationRead(this.id);
  @override
  List<Object?> get props => [id];
}

class DeleteUserNotification extends UserNotificationEvent {
  final int id;
  DeleteUserNotification(this.id);
  @override
  List<Object?> get props => [id];
}

class ClearError extends UserNotificationEvent {}
