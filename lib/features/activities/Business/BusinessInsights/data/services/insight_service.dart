import 'package:dio/dio.dart';
import 'package:hobby_sphere/core/network/globals.dart' as g;

class InsightService {
  final Dio _dio = g.dio();

  Future<Response> fetchBusinessBookings(String token, {int? itemId}) {
    return _dio.get(
      "${g.appServerRoot}/api/bookings/mybusinessbookings",
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
  }

  Future<Response> markBookingPaid(String token, int bookingId) {
    return _dio.put(
      "${g.appServerRoot}/api/bookings/mark-paid/$bookingId",
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
  }
}
