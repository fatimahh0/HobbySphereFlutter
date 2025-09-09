import 'package:dio/dio.dart';
import '../../../../../../core/network/globals.dart' as g;

class BusinessUsersService {
  final Dio _dio = g.dio();

  Future<List<dynamic>> fetchUsers(String token) async {
    final res = await _dio.get(
      "${g.appServerRoot}/api/business-users/my-users",
      options: Options(headers: {"Authorization": token}),
    );
    return res.data;
  }

  Future<Map<String, dynamic>> createUser(
    String token, {
    required String firstname,
    required String lastname,
    String? email,
    String? phoneNumber,
  }) async {
    final res = await _dio.post(
      "${g.appServerRoot}/api/business-users/create",
      data: {
        "firstname": firstname,
        "lastname": lastname,
        "email": email,
        "phoneNumber": phoneNumber,
      },
      options: Options(headers: {"Authorization": token}),
    );
    return res.data;
  }

  /// POST /api/items/book-cash
  /// Use to add an existing BusinessUser to an Activity manually (cash flow)
  Future<Map<String, dynamic>> bookCash({
    required String token,
    required int itemId,
    required int businessUserId,
    required int participants,
    required bool wasPaid,
  }) async {
    final res = await _dio.post(
      "${g.appServerRoot}/api/items/book-cash",
      data: {
        "itemId": itemId,
        "businessUserId": businessUserId,
        "participants": participants,
        "wasPaid": wasPaid,
      },
      options: Options(headers: {"Authorization": token}),
    );
    return (res.data as Map<String, dynamic>);
  }
}
