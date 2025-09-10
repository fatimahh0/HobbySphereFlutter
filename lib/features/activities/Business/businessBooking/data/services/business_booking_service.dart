// ===== Flutter 3.35.x =====
// Service: Business Bookings

import 'package:hobby_sphere/core/network/api_fetch.dart';
import 'package:hobby_sphere/core/network/api_methods.dart';

class BusinessBookingService {
  final _fetch = ApiFetch();
  static const _base = '/bookings';

  // GET /api/bookings/mybusinessbookings
  Future<List<dynamic>> getBusinessBookings(String token) async {
    final res = await _fetch.fetch(
      HttpMethod.get,
      '$_base/mybusinessbookings',
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.data is List) return res.data;
    throw Exception('Invalid bookings response');
  }

  Future<void> rejectBooking(String token, int id) async {
    await _fetch.fetch(
      HttpMethod.put,
      '$_base/booking/reject/$id',
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<void> unrejectBooking(String token, int id) async {
    await _fetch.fetch(
      HttpMethod.put,
      '$_base/booking/unreject/$id',
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<void> approveCancel(String token, int id) async {
    await _fetch.fetch(
      HttpMethod.put,
      '$_base/cancel/approve/$id',
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<void> rejectCancel(String token, int id) async {
    await _fetch.fetch(
      HttpMethod.put,
      '$_base/cancel/reject/$id',
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<void> markPaid(String token, int id) async {
    await _fetch.fetch(
      HttpMethod.put,
      '$_base/mark-paid/$id',
      headers: {'Authorization': 'Bearer $token'},
    );
  }
}
