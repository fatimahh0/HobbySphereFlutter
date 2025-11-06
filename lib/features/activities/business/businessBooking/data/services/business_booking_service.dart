// lib/features/activities/business/businessBooking/data/services/business_booking_service.dart
//// Flutter 3.35.x
//// Service layer that hits backend endpoints via ApiFetch

import 'package:hobby_sphere/core/network/api_methods.dart'; // HttpMethod
import 'package:hobby_sphere/core/network/api_fetch.dart'; // ApiFetch

class BusinessBookingService {
  // shared fetch wrapper
  final _fetch = ApiFetch(); // network client

  // base path for bookings
  static const _base = '/bookings'; // base path

  // load all bookings for current business
  Future<List<dynamic>> getBusinessBookings(String token) async {
    if (token.isEmpty) throw Exception('Missing business token'); // guard
    final res = await _fetch.fetch(
      HttpMethod.get, // GET
      '$_base/mybusinessbookings', // path
      headers: {
        'Authorization': 'Bearer $token', // auth
        'Accept': 'application/json', // json
      },
    );
    if (res.data is List) return res.data as List<dynamic>; // ok list
    throw Exception('Invalid bookings response'); // bad payload
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

  // reject booking
  Future<void> rejectBooking(String token, int id) =>
      _putNoop(token, '$_base/booking/reject/$id'); // PUT

  // unreject booking (back to pending)
  Future<void> unrejectBooking(String token, int id) =>
      _putNoop(token, '$_base/booking/unreject/$id'); // PUT

  // approve cancel request → becomes canceled
  Future<void> approveCancel(String token, int id) =>
      _putNoop(token, '$_base/cancel/approve/$id'); // PUT

  // reject cancel request → becomes cancel rejected
  Future<void> rejectCancel(String token, int id) =>
      _putNoop(token, '$_base/cancel/reject/$id'); // PUT

  // mark paid
  Future<void> markPaid(String token, int id) =>
      _putNoop(token, '$_base/mark-paid/$id'); // PUT
}
