// lib/features/activities/business/businessBooking/data/services/business_booking_service.dart
//// Flutter 3.35.x
//// Service layer that hits backend endpoints via ApiFetch

import 'package:hobby_sphere/core/network/api_methods.dart'; // HttpMethod
import 'package:hobby_sphere/core/network/api_fetch.dart'; // ApiFetch

class BusinessBookingService {
  // shared fetch wrapper
  final _fetch = ApiFetch(); // network client

  // base path for orders (was /bookings)
  static const _base = '/orders'; // base path

  // load all orders for current business
  Future<List<dynamic>> getBusinessBookings(String token) async {
    if (token.isEmpty) throw Exception('Missing business token'); // guard
    final res = await _fetch.fetch(
      HttpMethod.get, // GET
      '$_base/mybusinessorders', // /api/orders/mybusinessorders
      headers: {
        'Authorization': 'Bearer $token', // auth
        'Accept': 'application/json', // json
      },
    );
    if (res.data is List) return res.data as List<dynamic>; // ok list
    throw Exception('Invalid orders response'); // bad payload
  }

  // tiny helper to send empty PUT safely
  Future<void> _putNoop(String token, String path) async {
    if (token.isEmpty) throw Exception('Missing business token'); // guard
    await _fetch.fetch(
      HttpMethod.put, // PUT
      path, // path
      headers: {
        'Authorization': 'Bearer $token', // auth
        'Content-Type': 'application/json; charset=utf-8', // json
        'Accept': 'application/json', // json
      },
      data: const <String, dynamic>{}, // explicit empty json body
    );
  }

  // reject order → /api/orders/order/reject/{orderItemId}
  Future<void> rejectBooking(String token, int id) =>
      _putNoop(token, '$_base/order/reject/$id'); // PUT

  // unreject order (back to pending) → /api/orders/order/unreject/{orderItemId}
  Future<void> unrejectBooking(String token, int id) =>
      _putNoop(token, '$_base/order/unreject/$id'); // PUT

  // approve cancel request → becomes canceled
  // /api/orders/cancel/approve/{orderItemId}
  Future<void> approveCancel(String token, int id) =>
      _putNoop(token, '$_base/cancel/approve/$id'); // PUT

  // reject cancel request → becomes cancel rejected
  // /api/orders/cancel/reject/{orderItemId}
  Future<void> rejectCancel(String token, int id) =>
      _putNoop(token, '$_base/cancel/reject/$id'); // PUT

  // mark paid → /api/orders/mark-paid/{orderItemId}
  Future<void> markPaid(String token, int id) =>
      _putNoop(token, '$_base/mark-paid/$id'); // PUT
}
