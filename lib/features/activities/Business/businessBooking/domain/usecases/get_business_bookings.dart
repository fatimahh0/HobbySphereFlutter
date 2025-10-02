// lib/features/activities/Business/businessBooking/domain/usecases/get_business_bookings.dart
//// Flutter 3.35.x
//// Use case: load all bookings for current business

import '../entities/business_booking.dart'; // entity
import '../repositories/business_booking_repository.dart'; // contract

class GetBusinessBookings {
  // repo dependency
  final BusinessBookingRepository repo; // repository

  // constructor
  GetBusinessBookings(this.repo); // inject repo

  // invoke
  Future<List<BusinessBooking>> call(String token) {
    return repo.getBusinessBookings(token); // load from repo
  }
}
