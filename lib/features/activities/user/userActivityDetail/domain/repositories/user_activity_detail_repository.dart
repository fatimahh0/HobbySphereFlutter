import '../entities/user_activity_detail_entity.dart';

abstract class UserActivityDetailRepository {
  Future<UserActivityDetailEntity> getById(int id);
  Future<bool> checkAvailability({
    required int itemId,
    required int participants,
    required String bearerToken,
  });
  Future<int> confirmBooking({
    required int itemId,
    required int participants,
    required String stripePaymentId,
    required String bearerToken,
  });
}
