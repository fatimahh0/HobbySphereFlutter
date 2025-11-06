// lib/features/activities/Business/businessBooking/data/repositories/business_booking_repository_impl.dart
//// Flutter 3.35.x
//// Repository implementation that maps json to entities

import '../../domain/entities/business_booking.dart'; // entity
import '../../domain/repositories/business_booking_repository.dart'; // contract
import '../services/business_booking_service.dart'; // service

class BusinessBookingRepositoryImpl implements BusinessBookingRepository {
  // service dependency
  final BusinessBookingService service; // remote service

  // constructor
  BusinessBookingRepositoryImpl(this.service); // inject service

  @override
  Future<List<BusinessBooking>> getBusinessBookings(String token) async {
    // call service to get raw json list
    final raw = await service.getBusinessBookings(token); // remote list
    // map json → entity
    return raw.map((e) => BusinessBooking.fromJson(e)).toList(); // map all
  }

  @override
  Future<void> rejectBooking(String token, int id) =>
      service.rejectBooking(token, id); // forward

  @override
  Future<void> unrejectBooking(String token, int id) =>
      service.unrejectBooking(token, id); // forward

  @override
  Future<void> markPaid(String token, int id) => service.markPaid(token, id); // forward

  @override
  Future<void> approveCancel(String token, int id) =>
      service.approveCancel(token, id); // forward

  @override
  Future<void> rejectCancel(String token, int id) =>
      service.rejectCancel(token, id); // forward
}
