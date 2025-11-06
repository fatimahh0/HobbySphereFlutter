// lib/features/activities/business/businessBooking/domain/repositories/business_booking_repository.dart
//// Flutter 3.35.x
//// Repository contract for business bookings

import '../entities/business_booking.dart'; // entity

abstract class BusinessBookingRepository {
  // load all bookings for current business
  Future<List<BusinessBooking>> getBusinessBookings(String token); // GET

  // set booking to Rejected
  Future<void> rejectBooking(String token, int id); // PUT

  // move Rejected back to Pending
  Future<void> unrejectBooking(String token, int id); // PUT

  // mark a booking as Paid
  Future<void> markPaid(String token, int id); // PUT

  // approve a cancel request → booking becomes Canceled
  Future<void> approveCancel(String token, int id); // PUT

  // reject a cancel request → booking becomes CancelRejected
  Future<void> rejectCancel(String token, int id); // PUT
}
