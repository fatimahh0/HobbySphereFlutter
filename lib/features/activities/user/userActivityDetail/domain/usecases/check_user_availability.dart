import '../repositories/user_activity_detail_repository.dart';

class CheckUserAvailability {
  final UserActivityDetailRepository repo;
  const CheckUserAvailability(this.repo);

  Future<bool> call({
    required int itemId,
    required int participants,
    required String bearerToken,
  }) {
    return repo.checkAvailability(
      itemId: itemId,
      participants: participants,
      bearerToken: bearerToken,
    );
  }
}
