// small HTTP helper for user interests
import 'package:dio/dio.dart'; // http

class UserInterestsApi {
  final Dio dio; // http client
  UserInterestsApi(this.dio); // inject

  // build Authorization header safely
  Options _auth(String token) {
    final t = token.trim(); // trim spaces
    final bearer =
        t.startsWith('Bearer ') // ensure "Bearer "
        ? t
        : 'Bearer $t';
    return Options(
      headers: {
        'Authorization': bearer, // auth header
        'Accept': 'application/json', // expect json
      },
    );
  }

  // GET: /api/users/{userId}/interests  -> List<String> (names)
  Future<List<String>> getUserInterestNames(String token, int userId) async {
    final res = await dio.get(
      '/users/$userId/interests', // endpoint
      options: _auth(token), // auth
    );
    final data = res.data; // body
    if (data is List) {
      return data.map((e) => '$e').toList(); // normalize to List<String>
    }
    return const <String>[]; // fallback
  }

  // POST: /api/users/{userId}/UpdateInterest  -> body: List<int> (ids)
  Future<void> replaceUserInterests(
    String token,
    int userId,
    List<int> ids,
  ) async {
    await dio.post(
      '/users/$userId/UpdateInterest', // endpoint
      data: ids, // send ids
      options: _auth(token), // auth
    );
  }
}
