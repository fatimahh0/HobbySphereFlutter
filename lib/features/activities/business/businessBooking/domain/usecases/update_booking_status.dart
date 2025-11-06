// lib/features/activities/business/businessBooking/domain/usecases/update_booking_status.dart
//// Flutter 3.35.x
//// Use case: update booking status by action keyword

import '../repositories/business_booking_repository.dart'; // repo

class UpdateBookingStatus {
  // repo dependency
  final BusinessBookingRepository repo; // repository

  // constructor
  UpdateBookingStatus(this.repo); // inject repo

  // call with token, booking id, and action text
  Future<void> call(String token, int id, String action) {
    // normalize action to lower
    switch (action.toLowerCase()) {
      case 'rejected': // mark rejected
        return repo.rejectBooking(token, id);
      case 'pending': // back to pending (unreject)
        return repo.unrejectBooking(token, id);
      case 'paid': // mark paid
        return repo.markPaid(token, id);
      case 'cancel_approved': // approve cancel
        return repo.approveCancel(token, id);
      case 'cancel_rejected': // reject cancel
        return repo.rejectCancel(token, id);
      default: // unknown action
        throw ArgumentError('Unknown action: $action'); // fail fast
    }
  }
}
