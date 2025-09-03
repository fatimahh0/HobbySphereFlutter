import '../entities/business_booking.dart';
import '../repositories/business_booking_repository.dart';

class GetBusinessBookings {
  final BusinessBookingRepository repo;
  GetBusinessBookings(this.repo);

  Future<List<BusinessBooking>> call(String token) {
    return repo.getBusinessBookings(token);
  }
}
