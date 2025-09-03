// ===== Flutter 3.35.x =====
// UpdateBookingStatus — makes class callable like a function.

import '../repositories/business_booking_repository.dart';

class UpdateBookingStatus {
  final BusinessBookingRepository repo;
  UpdateBookingStatus(this.repo);

  // operator call: allows you to write updateStatus(id, 'Rejected')
  Future<void> call(String token, int id, String action) {
    switch (action.toLowerCase()) {
      case 'rejected':
        return repo.rejectBooking(token, id);
      case 'pending':
        return repo.unrejectBooking(token, id);
      case 'paid':
        return repo.markPaid(token, id);
      default:
        throw ArgumentError('Unknown action: $action');
    }
  }
}
