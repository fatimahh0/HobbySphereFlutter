import 'package:dio/dio.dart';

class TicketsService {
  final Dio dio;
  TicketsService(this.dio);

  // never double "Bearer"
  Options _auth(String token) {
    final t = (token).trim();
    final bearer = t.startsWith('Bearer ') ? t : 'Bearer $t';
    return Options(
      headers: {'Authorization': bearer, 'Accept': 'application/json'},
    );
  }

  Future<List<dynamic>> getByStatus(String token, String status) async {
    final s = (status).trim().toLowerCase();

    // endpoints:
    // pending  => server returns Pending + CancelRequested
    // completed => Completed
    // canceled  => Canceled
    final path = switch (s) {
      'pending' => '/bookings/mybookings/pending',
      'completed' => '/bookings/mybookings/completed',
      'cancelrequested' => '/bookings/mybookings/pending', // then client-filter
      'canceled' => '/bookings/mybookings/canceled',
      _ => '/bookings/mybookings',
    };

    try {
      final res = await dio.get(path, options: _auth(token));
      final data = res.data;
      if (data is List) return data;
      if (data is Map && data['content'] is List)
        return data['content'] as List;
      return const <dynamic>[];
    } on DioException {
      rethrow;
    }
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
