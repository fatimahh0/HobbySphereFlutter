import '../entities/insight_booking.dart';

/// Repository contract for Business Insights
abstract class InsightRepository {
  /// Fetch all bookings for the current business or specific item
  Future<List<InsightBooking>> getBookings(String token, int itemId);

  /// Mark a booking as paid
  Future<void> markBookingPaid(String token, int bookingId);
}
