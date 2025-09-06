// Contract: what operations notifications must support

import '../entities/business_notification.dart';

abstract class BusinessNotificationRepository {
  Future<List<BusinessNotification>> getNotifications(String token);
  Future<void> markAsRead(String token, int id);
  Future<void> deleteNotification(String token, int id);
  Future<int> getUnreadCount(String token);
}
