import '../repositories/insight_repository.dart';

class MarkBookingPaid {
  final InsightRepository repository;
  MarkBookingPaid(this.repository);

  Future<void> call(String token, int bookingId) {
    return repository.markBookingPaid(token, bookingId);
  }
}
