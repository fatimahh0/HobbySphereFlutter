// ===== Flutter 3.35.x =====
// RepositoryImpl: bridges domain <-> service

import '../../domain/entities/business_notification.dart';
import '../../domain/repositories/business_notification_repository.dart';
import '../models/business_notification_model.dart';
import '../services/business_notification_service.dart';

class BusinessNotificationRepositoryImpl
    implements BusinessNotificationRepository {
  final BusinessNotificationService service;

  BusinessNotificationRepositoryImpl(this.service);

  @override
  Future<List<BusinessNotification>> getNotifications(String token) async {
    final rawList = await service.getNotifications(token: token);

    // map raw JSON list -> domain entities
    return rawList.map((e) => BusinessNotificationModel.fromJson(e)).toList();
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

 

}
