import 'package:dio/dio.dart';
import 'package:hobby_sphere/core/network/globals.dart' as g;

import '../models/manager_invite_request.dart';
import '../models/manager_invite_response.dart';

class ManagerInviteService {
  Future<ManagerInviteResponse> sendInvite({
    required String token,
    required int businessId,
    required ManagerInviteRequest body,
  }) async {
    final dio = g.dio();
    final base = g.appServerRoot ?? '';
    final url = '$base/api/businesses/$businessId/send-manager-invite';
    final authValue = token.startsWith('Bearer ') ? token : 'Bearer $token';

    try {
      final res = await dio.post(
        url,
        data: body.toJson(),
        options: Options(
          headers: {
            'Authorization': authValue,
            'Content-Type': 'application/json',
          },
        ),
      );
      return ManagerInviteResponse.fromJson(res.data);
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = (data is Map && data['error'] != null)
          ? data['error'].toString()
          : (data is Map && data['message'] != null)
          ? data['message'].toString()
          : (e.message ?? 'Network error');
      return ManagerInviteResponse(error: msg);
    } catch (e) {
      return ManagerInviteResponse(error: e.toString());
    }
  }
}
