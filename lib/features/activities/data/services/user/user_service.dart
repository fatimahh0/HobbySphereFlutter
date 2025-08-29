// ===== Flutter 3.35.x =====
// services/user_service.dart
// Users API: list, password reset flow, profile visibility, status,
// suggestions, interests CRUD, Google user status, etc.

import 'package:hobby_sphere/core/network/api_fetch.dart'; // HTTP helper (Dio)
import 'package:hobby_sphere/core/network/api_methods.dart'; // GET / POST / PUT / DELETE

class UserService {
  // reuse the global Dio client via our wrapper
  final _fetch = ApiFetch(); // one shared instance

  // base path (our Dio baseUrl already ends with "/api")
  static const _base = '/users'; // -> <server>/api/users

  // ----------------- GET ALL USERS ------------------

  Future<List<dynamic>> getAllUsers(String token) async {
    // call GET /users/all with Authorization header
    final res = await _fetch.fetch(
      HttpMethod.get,
      '$_base/all',
      headers: {'Authorization': 'Bearer $token'},
    );

    // expect an array
    final data = res.data;
    if (data is! List) throw Exception('Invalid users list');
    return data; // return list
  }

  // ----------------- RESET PASSWORD ------------------

  Future<Map<String, dynamic>> sendResetEmail(String email) async {
    try {
      // POST /users/reset-password {email}
      final res = await _fetch.fetch(
        HttpMethod.post,
        '$_base/reset-password',
        data: {'email': email},
        headers: {'Content-Type': 'application/json'},
      );

      // mimic RN: {success, message}
      return {
        'success': true,
        'message': res.data?['message'] ?? 'Reset code sent to your email.',
      };
    } catch (_) {
      return {'success': false, 'message': 'Something went wrong.'};
    }
  }

  Future<Map<String, dynamic>> verifyResetCode(
    String email,
    String code,
  ) async {
    try {
      // POST /users/verify-reset-code {email, code}
      final res = await _fetch.fetch(
        HttpMethod.post,
        '$_base/verify-reset-code',
        data: {'email': email, 'code': code},
        headers: {'Content-Type': 'application/json'},
      );
      return {
        'success': true,
        'message': res.data?['message'] ?? 'Code verified successfully.',
      };
    } catch (_) {
      return {'success': false, 'message': 'Invalid code.'};
    }
  }

  Future<Map<String, dynamic>> updatePassword(
    String email,
    String newPassword,
  ) async {
    try {
      // POST /users/update-password {email, newPassword}
      final res = await _fetch.fetch(
        HttpMethod.post,
        '$_base/update-password',
        data: {'email': email, 'newPassword': newPassword},
        headers: {'Content-Type': 'application/json'},
      );
      return {
        'success': true,
        'message': res.data?['message'] ?? 'Password updated successfully.',
      };
    } catch (_) {
      return {'success': false, 'message': 'Failed to update password.'};
    }
  }

  // ----------------- PROFILE VISIBILITY ------------------

  Future<Map<String, dynamic>> updateProfileVisibility({
    required String token, // auth token
    required bool isPublic, // true/false
  }) async {
    try {
      // PUT /users/profile-visibility?isPublic=<bool>
      final res = await _fetch.fetch(
        HttpMethod.put,
        '$_base/profile-visibility?isPublic=$isPublic',
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      // RN returns string sometimes; normalize to {success, message}
      return {
        'success': true,
        'message': (res.data is String) ? res.data : 'Visibility updated.',
      };
    } catch (err) {
      return {'success': false, 'message': 'Failed to update visibility.'};
    }
  }

  // ----------------- GET USER BY ID ------------------

  Future<Map<String, dynamic>> getUserById({
    required String token,
    required int id,
  }) async {
    // GET /users/{id}
    final res = await _fetch.fetch(
      HttpMethod.get,
      '$_base/$id',
      headers: {'Authorization': 'Bearer $token'},
    );

    final data = res.data;
    if (data is! Map) throw Exception('Invalid user response');
    return Map<String, dynamic>.from(data);
  }

  // ----------------- UPDATE STATUS ------------------

  Future<Map<String, dynamic>> updateUserStatus({
    required String token,
    required int id,
    required String status, // e.g. "ACTIVE" | "SUSPENDED"
    required String password, // confirmation
  }) async {
    try {
      // PUT /users/{id}/status {status, password}
      final res = await _fetch.fetch(
        HttpMethod.put,
        '$_base/$id/status',
        data: {'status': status, 'password': password},
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return {
        'success': true,
        'message': (res.data is String)
            ? res.data
            : 'Status updated successfully.',
      };
    } catch (_) {
      return {'success': false, 'message': 'Failed to update status.'};
    }
  }

  // ----------------- FRIEND SUGGESTIONS ------------------

  Future<List<dynamic>> getSuggestionsByInterest({
    required String token,
    required int userId,
  }) async {
    // GET /users/{userId}/suggestions
    final res = await _fetch.fetch(
      HttpMethod.get,
      '$_base/$userId/suggestions',
      headers: {'Authorization': 'Bearer $token'},
    );

    final data = res.data;
    if (data is! List) throw Exception('Invalid suggestions response');
    return data;
  }

  // ----------------- GET USER STATUS ------------------

  Future<Map<String, dynamic>> getUserStatus({
    required String token,
    required int id,
  }) async {
    try {
      // GET /users/{id}/status
      final res = await _fetch.fetch(
        HttpMethod.get,
        '$_base/$id/status',
        headers: {'Authorization': 'Bearer $token'},
      );

      // RN does a replace on string "User status: X"; we normalize to {success, status}
      final payload = res.data;
      String status;
      if (payload is String) {
        status = payload.replaceFirst('User status: ', '').trim();
      } else if (payload is Map && payload['status'] != null) {
        status = payload['status'].toString();
      } else {
        status = payload?.toString() ?? '';
      }

      return {'success': true, 'status': status};
    } catch (_) {
      return {'success': false, 'message': 'Failed to fetch user status.'};
    }
  }

  // ----------------- CHECK STATUS BY CONTACT (before login) ------------------

  Future<Map<String, dynamic>> checkUserStatusByContact(String contact) async {
    try {
      // GET /users/status-check?contact=<encoded>
      final encoded = Uri.encodeComponent(contact);
      final res = await _fetch.fetch(
        HttpMethod.get,
        '$_base/status-check?contact=$encoded',
        headers: {'Content-Type': 'application/json'},
      );

      // RN returns { success, status, data }
      final payload = res.data;
      final status = (payload is Map && payload['status'] != null)
          ? payload['status']
          : (payload is String ? payload : null);

      return {'success': true, 'status': status, 'data': status ?? payload};
    } catch (_) {
      return {'success': false, 'message': 'Failed to check status.'};
    }
  }

  // ----------------- UPDATE GOOGLE USER STATUS ------------------

  Future<Map<String, dynamic>> updateGoogleUserStatus({
    required String token,
    required String status, // new status to set
  }) async {
    try {
      // PUT /users/auth/google/status {status}
      final res = await _fetch.fetch(
        HttpMethod.put,
        '$_base/auth/google/status',
        data: {'status': status},
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      // normalize to {success, message, status, googleId}
      final d = res.data;
      return {
        'success': true,
        'message': d?['message'] ?? 'Google user status updated.',
        'status': d?['status'],
        'googleId': d?['googleId'],
      };
    } catch (_) {
      return {
        'success': false,
        'message': 'Failed to update Google user status.',
      };
    }
  }

  // ----------------- INTERESTS ------------------

  Future<dynamic> getUserInterests(int userId) async {
    // GET /users/{userId}/interests
    final res = await _fetch.fetch(HttpMethod.get, '$_base/$userId/interests');
    return res.data; // backend may return array or object
  }

  Future<Map<String, dynamic>> updateUserInterest({
    required int userId,
    required int interestId,
    required String newName, // new interest name
  }) async {
    try {
      // PUT /users/{userId}/interests/{interestId} { name: "..." }
      final res = await _fetch.fetch(
        HttpMethod.put,
        '$_base/$userId/interests/$interestId',
        data: {'name': newName},
        headers: {'Content-Type': 'application/json'},
      );

      return {
        'success': true,
        'message': res.data?['message'] ?? 'Interest updated.',
      };
    } catch (_) {
      return {'success': false, 'message': 'Failed to update interest.'};
    }
  }

  Future<Map<String, dynamic>> deleteUserInterest({
    required int userId,
    required int interestId,
  }) async {
    try {
      // DELETE /users/{userId}/interests/{interestId}
      final res = await _fetch.fetch(
        HttpMethod.delete,
        '$_base/$userId/interests/$interestId',
        headers: {'Content-Type': 'application/json'},
      );

      return {
        'success': true,
        'message': res.data?['message'] ?? 'Interest deleted.',
      };
    } catch (_) {
      return {'success': false, 'message': 'Failed to delete interest.'};
    }
  }

  Future<Map<String, dynamic>> replaceUserInterests({
    required int userId,
    required List<int> selectedInterestIds, // array like [1,2,3]
  }) async {
    try {
      // POST /users/{userId}/UpdateInterest  (note: POST per RN code)
      final res = await _fetch.fetch(
        HttpMethod.post,
        '$_base/$userId/UpdateInterest',
        data: selectedInterestIds, // send array directly
        headers: {'Content-Type': 'application/json'},
      );

      return {
        'success': true,
        'message':
            res.data?['message'] ?? 'User interests updated successfully.',
      };
    } catch (_) {
      return {'success': false, 'message': 'Failed to update interests.'};
    }
  }
}
