import '../repositories/user_activity_detail_repository.dart';

class ConfirmUserBooking {
  final UserActivityDetailRepository repo;
  const ConfirmUserBooking(this.repo);

  Future<int> call({
    required int itemId,
    required int participants,
    required String stripePaymentId,
    required String bearerToken,
  }) {
    return repo.confirmBooking(
      itemId: itemId,
      participants: participants,
      stripePaymentId: stripePaymentId,
      bearerToken: bearerToken,
    );
  }
}
