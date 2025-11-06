// ===== Flutter 3.35.x =====
// Business Booking Service
// Endpoints for a business to manage bookings:
// - getMyBusinessBookings
// - rejectBooking
// - unrejectBooking
// - getBookingsByItemId

import 'package:hobby_sphere/core/network/api_fetch.dart'; // universal fetch
import 'package:hobby_sphere/core/network/api_methods.dart'; // GET / PUT

class BusinessBookingService {
  final _fetch = ApiFetch(); // reuse the global Dio client
  static const _base =
      '/bookings'; // base path (Dio baseUrl already ends with /api)

  // ------------------------------------------------------------
  // GET /api/bookings/mybusinessbookings
  Future<List<dynamic>> getMyBusinessBookings(String token) async {
    if (token.isEmpty) throw Exception('Missing business token');

    final res = await _fetch.fetch(
      HttpMethod.get,
      '$_base/mybusinessbookings',
      headers: {'Authorization': 'Bearer $token'},
    );

    final data = res.data;
    if (data is! List) throw Exception('Invalid bookings list');
    return data;
  }

  // ------------------------------------------------------------
  // PUT /api/bookings/booking/reject/{bookingId}
  Future<Map<String, dynamic>> rejectBooking({
    required int bookingId,
    required String token,
  }) async {
    if (token.isEmpty) throw Exception('Missing business token');

    final res = await _fetch.fetch(
      HttpMethod.put,
      '$_base/booking/reject/$bookingId',
      data: {}, // empty body
      headers: {'Authorization': 'Bearer $token'},
    );

    final data = res.data;
    if (data is! Map) throw Exception('Invalid reject response');
    return Map<String, dynamic>.from(data);
  }

  // ------------------------------------------------------------
  // PUT /api/bookings/booking/unreject/{bookingId}
  Future<Map<String, dynamic>> unrejectBooking({
    required int bookingId,
    required String token,
  }) async {
    if (token.isEmpty) throw Exception('Missing business token');

    final res = await _fetch.fetch(
      HttpMethod.put,
      '$_base/booking/unreject/$bookingId',
      data: {}, // empty body
      headers: {'Authorization': 'Bearer $token'},
    );

    final data = res.data;
    if (data is! Map) throw Exception('Invalid unreject response');
    return Map<String, dynamic>.from(data);
  }

  // ------------------------------------------------------------
  // GET /api/bookings/item/{itemId}/bookings
  Future<List<dynamic>> getBookingsByItemId({
    required String token,
    required int itemId,
  }) async {
    if (token.isEmpty) throw Exception('Missing business token');

    final res = await _fetch.fetch(
      HttpMethod.get,
      '$_base/item/$itemId/bookings',
      headers: {'Authorization': 'Bearer $token'},
    );

    final data = res.data;
    if (data is! List) throw Exception('Invalid bookings response');
    return data;
  }
}
