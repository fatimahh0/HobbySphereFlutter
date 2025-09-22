import '../repositories/user_notification_repository.dart';

class GetUnreadUserNotificationsCount {
  final UserNotificationRepository repository;
  GetUnreadUserNotificationsCount(this.repository);

  Future<int> call(String token) => repository.getUnreadCount(token);
}
