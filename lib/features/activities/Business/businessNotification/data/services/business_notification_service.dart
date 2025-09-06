// ===== Flutter 3.35.x =====
// BusinessNotificationService — calls backend to fetch/manage notifications.

import 'package:hobby_sphere/core/network/api_fetch.dart';
import 'package:hobby_sphere/core/network/api_methods.dart';

class BusinessNotificationService {
  // Shared HTTP client wrapper (based on Dio)
  final _fetch = ApiFetch();

  // Base path for notification APIs
  static const _base = '/notifications/business';

  /// Get all notifications for a business.
  Future<List<dynamic>> getNotifications({required String token}) async {
    // GET /api/notifications/business
    final res = await _fetch.fetch(
      HttpMethod.get,
      _base,
      headers: {'Authorization': 'Bearer $token'},
    );
    return List<dynamic>.from(res.data);
  }

  /// Mark a business notification as read.
  Future<void> markAsRead({required String token, required int id}) async {
    // PUT /api/notifications/business/{id}/read
    await _fetch.fetch(
      HttpMethod.put,
      '$_base/$id/read',
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  /// Delete a business notification.
  Future<void> deleteNotification({
    required String token,
    required int id,
  }) async {
    // DELETE /api/notifications/business/{id}
    await _fetch.fetch(
      HttpMethod.delete,
      '$_base/$id',
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  /// Get unread notifications count.
  Future<int> getUnreadCount({required String token}) async {
    // GET /api/notifications/business/unread-count
    final res = await _fetch.fetch(
      HttpMethod.get,
      '$_base/unread-count',
      headers: {'Authorization': 'Bearer $token'},
    );
    return res.data as int;
  }

  /// Get total notifications count.
  Future<int> getTotalCount({required String token}) async {
    // GET /api/notifications/business/count
    final res = await _fetch.fetch(
      HttpMethod.get,
      '$_base/count',
      headers: {'Authorization': 'Bearer $token'},
    );
    return res.data as int;
  }
}
