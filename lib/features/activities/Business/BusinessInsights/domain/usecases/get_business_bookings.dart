import '../entities/insight_booking.dart';
import '../repositories/insight_repository.dart';

class GetBusinessBookings {
  final InsightRepository repository;
  GetBusinessBookings(this.repository);

  Future<List<InsightBooking>> call(String token) {
    return repository.getBusinessBookings(token);
  }
}
