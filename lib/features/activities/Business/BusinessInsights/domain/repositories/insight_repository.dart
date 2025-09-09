import '../entities/insight_booking.dart';

abstract class InsightRepository {
  Future<List<InsightBooking>> getBusinessBookings(String token);
  Future<void> markBookingPaid(String token, int bookingId);
}
