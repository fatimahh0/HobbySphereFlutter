import '../repositories/social_repository.dart';

class GetUnreadNotifications {
  final SocialRepository repo;
  GetUnreadNotifications(this.repo);
  Future<int> call(String token) => repo.getUnreadNotificationCount(token);
}
