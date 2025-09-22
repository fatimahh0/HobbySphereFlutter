import 'package:hobby_sphere/core/network/api_fetch.dart';
import 'package:hobby_sphere/core/network/api_methods.dart';

class UserNotificationService {
  final _fetch = ApiFetch();
  // Base path for USER notifications (from your controller)
  static const _base = '/notifications';

  Future<List<dynamic>> getNotifications({required String token}) async {
    final res = await _fetch.fetch(
      HttpMethod.get,
      _base,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    final data = res.data;
    if (data is List) return data;
    if (data is Map && data['content'] is List)
      return List<dynamic>.from(data['content']);
    return const [];
  }

  Future<void> markAsRead({required String token, required int id}) async {
    await _fetch.fetch(
      HttpMethod.put,
      '$_base/$id/read',
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
  }

  Future<void> deleteNotification({
    required String token,
    required int id,
  }) async {
    await _fetch.fetch(
      HttpMethod.delete,
      '$_base/$id',
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
  }

  Future<int> getUnreadCount({required String token}) async {
    final res = await _fetch.fetch(
      HttpMethod.get,
      '$_base/unread-count',
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    return (res.data is num)
        ? (res.data as num).toInt()
        : int.tryParse('${res.data}') ?? 0;
  }

  Future<int> getTotalCount({required String token}) async {
    final res = await _fetch.fetch(
      HttpMethod.get,
      '$_base/count',
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    return (res.data is num)
        ? (res.data as num).toInt()
        : int.tryParse('${res.data}') ?? 0;
  }
}
