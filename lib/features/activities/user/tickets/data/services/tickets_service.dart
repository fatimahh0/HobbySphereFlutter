// lib/features/tickets/data/services/tickets_service.dart
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
    // pending   => server returns Pending + CancelRequested
    // completed => Completed
    // canceled  => Canceled
    //
    // backend:
    //  GET /api/orders/myorders
    //  GET /api/orders/myorders/pending
    //  GET /api/orders/myorders/completed
    //  GET /api/orders/myorders/canceled
    final path = switch (s) {
      'pending' => '/orders/myorders/pending',
      'completed' => '/orders/myorders/completed',
      'cancelrequested' => '/orders/myorders/pending', // then client-filter
      'canceled' => '/orders/myorders/canceled',
      _ => '/orders/myorders',
    };

    try {
      final res = await dio.get(path, options: _auth(token));
      final data = res.data;
      if (data is List) return data;
      if (data is Map && data['content'] is List) {
        return data['content'] as List;
      }
      return const <dynamic>[];
    } on DioException {
      rethrow;
    }
  }

  // ✅ Backend now: PUT /api/orders/cancel/request/{orderItemId}
  Future<void> requestCancel(
    String token,
    int orderItemId,
    String reason,
  ) async {
    await dio.put(
      '/orders/cancel/request/$orderItemId',
      data: {'reason': reason}, // backend accepts/ignores; safe to send
      options: _auth(token),
    );
  }

  // direct cancel by user (if you expose it in UI)
  // PUT /api/orders/cancel/{orderItemId}
  Future<void> cancelBooking(String token, int orderItemId) async {
    await dio.put('/orders/cancel/$orderItemId', options: _auth(token));
  }

  // reset back to pending → PUT /api/orders/pending/{orderItemId}
  Future<void> resetToPending(String token, int orderItemId) async {
    await dio.put('/orders/pending/$orderItemId', options: _auth(token));
  }

  // delete canceled → DELETE /api/orders/delete/{orderItemId}
  Future<void> deleteCanceled(String token, int orderItemId) async {
    await dio.delete('/orders/delete/$orderItemId', options: _auth(token));
  }
}
