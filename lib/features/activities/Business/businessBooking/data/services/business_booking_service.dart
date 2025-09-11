import 'package:hobby_sphere/core/network/api_fetch.dart';
import 'package:hobby_sphere/core/network/api_methods.dart';

class BusinessBookingService {
  final _fetch = ApiFetch();
  static const _base = '/bookings';

  Future<List<dynamic>> getBusinessBookings(String token) async {
    if (token.isEmpty) throw Exception('Missing business token');
    final res = await _fetch.fetch(
      HttpMethod.get,
      '$_base/mybusinessbookings',
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    if (res.data is List) return res.data;
    throw Exception('Invalid bookings response');
  }

  Future<void> _putNoop(String token, String path) async {
    if (token.isEmpty) throw Exception('Missing business token');
    await _fetch.fetch(
      HttpMethod.put,
      path,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
      },
      // send an explicit empty JSON object (Dio sometimes collapses null)
      data: const <String, dynamic>{},
    );
  }

  Future<void> rejectBooking(String token, int id) =>
      _putNoop(token, '$_base/booking/reject/$id');

  Future<void> unrejectBooking(String token, int id) =>
      _putNoop(token, '$_base/booking/unreject/$id');

  Future<void> approveCancel(String token, int id) =>
      _putNoop(token, '$_base/cancel/approve/$id');

  Future<void> rejectCancel(String token, int id) =>
      _putNoop(token, '$_base/cancel/reject/$id');

  Future<void> markPaid(String token, int id) =>
      _putNoop(token, '$_base/mark-paid/$id');
}
