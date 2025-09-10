// ===== Flutter 3.35.x =====
// UpdateBookingStatus — supports reject, unreject, cancel approve/reject, markPaid.

import '../repositories/business_booking_repository.dart';

class UpdateBookingStatus {
  final BusinessBookingRepository repo;
  UpdateBookingStatus(this.repo);

  Future<void> call(String token, int id, String action) {
    switch (action.toLowerCase()) {
      case 'rejected':
        return repo.rejectBooking(token, id);
      case 'pending': // unreject → back to pending
        return repo.unrejectBooking(token, id);
      case 'paid':
        return repo.markPaid(token, id);
      case 'cancel_approved':
        return repo.approveCancel(token, id);
      case 'cancel_rejected':
        return repo.rejectCancel(token, id);
      default:
        throw ArgumentError('Unknown action: $action');
    }
  }
}
