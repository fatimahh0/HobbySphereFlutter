
import 'package:hobby_sphere/features/activities/user/userNotification/domain/entities/user_notification.dart';
import 'package:hobby_sphere/features/activities/user/userNotification/domain/repositories/user_notification_repository.dart';

class GetUserNotifications {
  final UserNotificationRepository repository;
  GetUserNotifications(this.repository);

  Future<List<UserNotification>> call(String token) {
    return repository.getNotifications(token);
  }
}
