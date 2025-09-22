import 'package:hobby_sphere/features/activities/user/userNotification/domain/entities/user_notification.dart';

abstract class UserNotificationRepository {
  Future<List<UserNotification>> getNotifications(String token);
  Future<void> markAsRead(String token, int id);
  Future<void> deleteNotification(String token, int id);
  Future<int> getUnreadCount(String token);
  Future<int> getTotalCount(String token); // optional, for parity
}
