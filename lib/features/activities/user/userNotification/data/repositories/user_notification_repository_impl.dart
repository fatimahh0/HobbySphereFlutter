

import 'package:hobby_sphere/features/activities/user/userNotification/data/models/user_notification_model.dart';
import 'package:hobby_sphere/features/activities/user/userNotification/data/services/user_notification_service.dart';
import 'package:hobby_sphere/features/activities/user/userNotification/domain/entities/user_notification.dart';
import 'package:hobby_sphere/features/activities/user/userNotification/domain/repositories/user_notification_repository.dart';

class UserNotificationRepositoryImpl implements UserNotificationRepository {
  final UserNotificationService service;
  UserNotificationRepositoryImpl(this.service);

  @override
  Future<List<UserNotification>> getNotifications(String token) async {
    final raw = await service.getNotifications(token: token);
    return raw
        .map((e) => UserNotificationModel.fromJson(e))
        .toList(growable: false);
  }

  @override
  Future<void> markAsRead(String token, int id) {
    return service.markAsRead(token: token, id: id);
  }

  @override
  Future<void> deleteNotification(String token, int id) {
    return service.deleteNotification(token: token, id: id);
  }

  @override
  Future<int> getUnreadCount(String token) {
    return service.getUnreadCount(token: token);
  }

  @override
  Future<int> getTotalCount(String token) {
    return service.getTotalCount(token: token);
  }
}
