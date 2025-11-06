
import 'package:hobby_sphere/features/activities/Business/businessNotification/domain/repositories/business_notification_repository.dart';

class GetUnreadBusinessNotificationsCount {
  final BusinessNotificationRepository repository;
  GetUnreadBusinessNotificationsCount(this.repository);

  Future<int> call(String token) {
    return repository.getUnreadCount(token);
  }
}
