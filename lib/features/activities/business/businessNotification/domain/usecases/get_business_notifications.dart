import '../entities/business_notification.dart';
import '../repositories/business_notification_repository.dart';

// UseCase: fetch notifications for business
class GetBusinessNotifications {
  final BusinessNotificationRepository repository;
  GetBusinessNotifications(this.repository);

  Future<List<BusinessNotification>> call(String token) {
    return repository.getNotifications(token);
  }
}
