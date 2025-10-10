// Flutter 3.35.x — simple and clean
// Every line has a short comment.

import 'package:dio/dio.dart'; // HTTP client
import '../../../../../../core/network/globals.dart' as g; // your Dio factory

class BusinessUsersService {
  final Dio _dio = g.dio(); // shared Dio

  // Helper: ensure "Bearer " prefix is there
  String _bearer(String token) => token.startsWith('Bearer ')
      ? token // already prefixed
      : 'Bearer $token'; // add prefix

  // ==== GET /api/business-users/my-users ====
  Future<List<dynamic>> fetchUsers(String token) async {
    final res = await _dio.get(
      '${g.appServerRoot}/business-users/my-users', // url
      options: Options(
        headers: {'Authorization': _bearer(token)}, // ✅ Bearer prefix
      ),
    );
    // backend returns JSON array -> keep as List<dynamic>
    return res.data as List<dynamic>;
  }

  // ==== POST /api/business-users/create ====
  Future<Map<String, dynamic>> createUser(
    String token, {
    required String firstname, // required
    required String lastname, // required
    String? email, // optional
    String? phoneNumber, // optional
  }) async {
    final res = await _dio.post(
      '${g.appServerRoot}/business-users/create', // url
      data: {
        'firstName': firstname, // ✅ correct casing
        'lastName': lastname, // ✅ correct casing
        'email': email, // may be null -> omitted by backend if null
        'phoneNumber': phoneNumber,
      },
      options: Options(
        headers: {
          'Authorization': _bearer(token), // ✅ Bearer prefix
          'Content-Type': 'application/json', // send JSON body
        },
      ),
    );
    // backend returns created entity -> Map
    return res.data as Map<String, dynamic>;
  }

  // ==== POST /api/items/book-cash ====
  // NOTE: Your server currently returns 501 "Not implemented".
  // We handle that nicely so UI doesn't crash.
  Future<Map<String, dynamic>> bookCash({
    required String token, // business token required
    required int itemId, // item id
    required int businessUserId, // client id (belongs to same business)
    required int participants, // seats to book
    required bool wasPaid, // cash collected flag
  }) async {
    try {
      final res = await _dio.post(
        '${g.appServerRoot}/items/book-cash', // url
        data: {
          'itemId': itemId, // required
          'businessUserId': businessUserId, // required
          'participants': participants, // required
          'wasPaid': wasPaid, // required
        },
        options: Options(
          headers: {
            'Authorization': _bearer(token), // ✅ Bearer prefix
            'Content-Type': 'application/json', // JSON body
          },
          validateStatus: (code) => true, // let us handle errors manually
        ),
      );

      // If server not implemented (501), return a friendly payload
      if (res.statusCode == 501) {
        return {
          'ok': false,
          'status': 501,
          'error': 'Cash booking is not implemented on the server.',
        };
      }

      // Any other non-2xx -> bubble up a structured error
      if (res.statusCode == null ||
          res.statusCode! < 200 ||
          res.statusCode! >= 300) {
        return {
          'ok': false,
          'status': res.statusCode,
          'error': res.data?.toString() ?? 'Unknown error',
        };
      }

      // Success (server returns booking entity or message)
      return {'ok': true, 'status': res.statusCode, 'data': res.data}
          as Map<String, dynamic>;
    } on DioException catch (e) {
      // Network/parse errors -> uniform error map
      return {
        'ok': false,
        'status': e.response?.statusCode,
        'error': e.response?.data?.toString() ?? e.message ?? 'Network error',
      };
    }
  }
}
