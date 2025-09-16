import 'package:dio/dio.dart';

class TicketsService {
  final Dio dio;
  TicketsService(this.dio);

  // Helper to add bearer
  Options _auth(String token) =>
      Options(headers: {'Authorization': 'Bearer $token'});

  Future<List<dynamic>> getByStatus(String token, String status) async {
    // backend endpoints mapped to tabs
    final path = switch (status) {
      'Pending' => '/bookings/mybookings/pending',
      'Completed' => '/bookings/mybookings/completed',
      'Canceled' => '/bookings/mybookings/canceled',
      _ => '/bookings/mybookings',
    };
    final res = await dio.get(path, options: _auth(token));
    return (res.data as List);
  }

  Future<void> requestCancel(String token, int bookingId, String reason) async {
    await dio.post(
      '/bookings/cancel/request/$bookingId',
      data: {'reason': reason},
      options: _auth(token),
    );
  }

  Future<void> deleteCanceled(String token, int bookingId) async {
    await dio.delete('/bookings/delete/$bookingId', options: _auth(token));
  }
}
