// ===== Flutter 3.35.x =====
// Booking service: availability, confirm, cash booking, my bookings,
// and booking lifecycle actions (cancel, pending, refund, etc.).

import 'package:hobby_sphere/core/network/api_fetch.dart'; // axios-like helper
import 'package:hobby_sphere/core/network/api_methods.dart'; // GET/POST/PUT/DELETE

class BookingService {
  final _fetch = ApiFetch(); // shared fetch instance
  static const _itemsBase = '/items'; // items base path
  static const _bookingsBase = '/bookings'; // bookings base path

  // ---------------------------------------------------------
  // GET /api/items/{id}/check-availability?participants=X
  Future<Map<String, dynamic>> checkAvailabilityForBook({
    required String token, // user token
    required int itemId, // item id
    required int participants, // participants count
  }) async {
    final res = await _fetch.fetch(
      HttpMethod.get,
      '$_itemsBase/$itemId/check-availability',
      data: {'participants': participants},
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = res.data;
    if (data is! Map || data['available'] is! bool) {
      throw Exception('Invalid availability response');
    }
    return Map<String, dynamic>.from(data);
  }

  // ---------------------------------------------------------
  // POST /api/items/confirm-booking
  Future<Map<String, dynamic>> confirmBooking({
    required String token,
    required int itemId,
    required int participants,
    required String stripePaymentId,
  }) async {
    final body = {
      'itemId': itemId,
      'participants': participants,
      'stripePaymentId': stripePaymentId,
    };
    final res = await _fetch.fetch(
      HttpMethod.post,
      '$_itemsBase/confirm-booking',
      data: body,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    final data = res.data;
    if (data is! Map) throw Exception('Invalid confirm response');
    return Map<String, dynamic>.from(data);
  }

  // ---------------------------------------------------------
  // POST /api/items/book-cash
  Future<Map<String, dynamic>> bookCashForClient({
    required String token,
    required Map<String, dynamic> body,
  }) async {
    final res = await _fetch.fetch(
      HttpMethod.post,
      '$_itemsBase/book-cash',
      data: body,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    final data = res.data;
    if (data is! Map) throw Exception('Invalid book-cash response');
    return Map<String, dynamic>.from(data);
  }

  // ---------------------------------------------------------
  // GET /api/bookings/mybookings
  Future<List<dynamic>> getMyBookings(String token) async {
    final res = await _fetch.fetch(
      HttpMethod.get,
      '$_bookingsBase/mybookings',
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = res.data;
    return (data is List) ? data : [];
  }

  // ---------------------------------------------------------
  // GET /api/bookings/mybookings/pending
  Future<List<dynamic>> getPendingTickets(String token) async {
    final res = await _fetch.fetch(
      HttpMethod.get,
      '$_bookingsBase/mybookings/pending',
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = res.data;
    return (data is List) ? data : (data?['data'] ?? []);
  }

  // GET /api/bookings/mybookings/completed
  Future<List<dynamic>> getCompletedTickets(String token) async {
    final res = await _fetch.fetch(
      HttpMethod.get,
      '$_bookingsBase/mybookings/completed',
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = res.data;
    return (data is List) ? data : (data?['data'] ?? []);
  }

  // GET /api/bookings/mybookings/canceled
  Future<List<dynamic>> getCanceledTickets(String token) async {
    final res = await _fetch.fetch(
      HttpMethod.get,
      '$_bookingsBase/mybookings/canceled',
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = res.data;
    return (data is List) ? data : (data?['data'] ?? []);
  }

  // ---------------------------------------------------------
  // PUT /api/bookings/cancel/{bookingId}
  Future<Map<String, dynamic>> cancelTicket({
    required int bookingId,
    required String token,
  }) async {
    final res = await _fetch.fetch(
      HttpMethod.put,
      '$_bookingsBase/cancel/$bookingId',
      data: {},
      headers: {'Authorization': 'Bearer $token'},
    );
    return Map<String, dynamic>.from(res.data);
  }

  // PUT /api/bookings/pending/{bookingId}
  Future<Map<String, dynamic>> pendingTicket({
    required int bookingId,
    required String token,
  }) async {
    final res = await _fetch.fetch(
      HttpMethod.put,
      '$_bookingsBase/pending/$bookingId',
      data: {},
      headers: {'Authorization': 'Bearer $token'},
    );
    return Map<String, dynamic>.from(res.data);
  }

  // DELETE /api/bookings/delete/{bookingId}
  Future<Map<String, dynamic>> deleteCanceledTicket({
    required int bookingId,
    required String token,
  }) async {
    final res = await _fetch.fetch(
      HttpMethod.delete,
      '$_bookingsBase/delete/$bookingId',
      headers: {'Authorization': 'Bearer $token'},
    );
    return Map<String, dynamic>.from(res.data);
  }

  // POST /api/bookings/refund/{bookingId}
  Future<Map<String, dynamic>> refundTicket({
    required int bookingId,
    required String token,
  }) async {
    final res = await _fetch.fetch(
      HttpMethod.post,
      '$_bookingsBase/refund/$bookingId',
      headers: {'Authorization': 'Bearer $token'},
    );
    return Map<String, dynamic>.from(res.data);
  }

  // ---------------------------------------------------------
  // POST /api/bookings/cancel/request/{bookingId}
  Future<Map<String, dynamic>> requestCancelTicket({
    required int bookingId,
    required String reason,
    required String token,
  }) async {
    final res = await _fetch.fetch(
      HttpMethod.post,
      '$_bookingsBase/cancel/request/$bookingId',
      data: {'reason': reason.trim()},
      headers: {'Authorization': 'Bearer $token'},
    );
    return Map<String, dynamic>.from(res.data);
  }

  // PUT /api/bookings/cancel/approve/{bookingId}
  Future<Map<String, dynamic>> approveCancelRequest({
    required int bookingId,
    required String token,
  }) async {
    final res = await _fetch.fetch(
      HttpMethod.put,
      '$_bookingsBase/cancel/approve/$bookingId',
      data: {},
      headers: {'Authorization': 'Bearer $token'},
    );
    return Map<String, dynamic>.from(res.data);
  }

  // PUT /api/bookings/cancel/reject/{bookingId}
  Future<Map<String, dynamic>> rejectCancelRequest({
    required int bookingId,
    required String token,
  }) async {
    final res = await _fetch.fetch(
      HttpMethod.put,
      '$_bookingsBase/cancel/reject/$bookingId',
      data: {},
      headers: {'Authorization': 'Bearer $token'},
    );
    return Map<String, dynamic>.from(res.data);
  }

  // PUT /api/bookings/cancel/mark-refunded/{bookingId}
  Future<Map<String, dynamic>> markBookingManuallyRefunded({
    required int bookingId,
    required String token,
  }) async {
    final res = await _fetch.fetch(
      HttpMethod.put,
      '$_bookingsBase/cancel/mark-refunded/$bookingId',
      data: {},
      headers: {'Authorization': 'Bearer $token'},
    );
    return Map<String, dynamic>.from(res.data);
  }
}
