// ===== Flutter 3.35.x =====
// services/message_service.dart
// Messaging APIs: send (multipart), get conversation, mark read (PATCH),
// delete message, and unread counts by contact.

import 'package:dio/dio.dart'; // FormData, Multipart
import 'package:hobby_sphere/core/network/api_fetch.dart'; // universal fetch (Dio inside)
import 'package:hobby_sphere/core/network/api_methods.dart'; // GET / POST / PATCH / DELETE

class MessageService {
  // create one helper that reuses the global Dio client
  final _fetch = ApiFetch(); // shared HTTP helper

  // base path for messages (global baseUrl already contains "/api")
  static const _base = '/messages'; // -> <server>/api/messages

  // ------------------------------------------------------------
  // POST /api/messages/send/{receiverId}
  // Send message with multipart (text + optional file)
  Future<Map<String, dynamic>> sendMessage({
    required String token, // JWT token
    required int receiverId, // receiver user id
    required FormData formData, // multipart form (text/file)
  }) async {
    // call POST with multipart + Authorization
    final res = await _fetch.fetch(
      HttpMethod.post, // HTTP method
      '$_base/send/$receiverId', // endpoint path
      data: formData, // multipart body
      headers: {
        'Authorization': 'Bearer $token', // bearer token
        'Content-Type': 'multipart/form-data', // multipart header
      },
    );

    // read json payload
    final data = res.data; // response json
    if (data is! Map) throw Exception('Invalid send response'); // guard object
    return Map<String, dynamic>.from(data); // return as map
  }

  // (optional) small helper to build the multipart form
  // usage:
  // final form = MessageService.buildForm(text: "hi", filePath: pickedPath);
  static Future<FormData> buildForm({
    String? text, // message text
    String? filePath, // local file path (optional)
    String fileFieldName = 'file', // backend field name
  }) async {
    final f = FormData(); // init form
    if (text != null && text.trim().isNotEmpty) {
      f.fields.add(MapEntry('text', text.trim())); // add text field
    }
    if (filePath != null && filePath.isNotEmpty) {
      final name = filePath.split('/').last; // file name
      f.files.add(
        MapEntry(
          fileFieldName, // field key
          await MultipartFile.fromFile(filePath, filename: name), // file part
        ),
      );
    }
    return f; // ready form
  }

  // ------------------------------------------------------------
  // GET /api/messages/conversation/{userId}
  // Fetch conversation between me and userId
  Future<List<dynamic>> getConversation({
    required String token, // JWT token
    required int userId, // other user id
  }) async {
    final res = await _fetch.fetch(
      HttpMethod.get, // GET
      '$_base/conversation/$userId', // endpoint
      headers: {'Authorization': 'Bearer $token'}, // auth header
    );

    final data = res.data; // response json
    if (data is! List) throw Exception('Invalid conversation'); // guard list
    return data; // return messages list
  }

  // ------------------------------------------------------------
  // PATCH /api/messages/{messageId}/read
  // Mark a single message as read
  Future<Map<String, dynamic>> markMessageAsRead({
    required String token, // JWT token
    required int messageId, // message id
  }) async {
    final res = await _fetch.fetch(
      HttpMethod.patch, // PATCH
      '$_base/$messageId/read', // endpoint
      data: {}, // empty body like RN
      headers: {'Authorization': 'Bearer $token'}, // auth header
    );

    final data = res.data; // response json
    if (data is! Map) throw Exception('Invalid mark-read response'); // guard
    return Map<String, dynamic>.from(data); // return map
  }

  // ------------------------------------------------------------
  // DELETE /api/messages/{messageId}
  // Delete one message by id
  Future<Map<String, dynamic>> deleteMessage({
    required String token, // JWT token
    required int messageId, // message id
  }) async {
    final res = await _fetch.fetch(
      HttpMethod.delete, // DELETE
      '$_base/$messageId', // endpoint
      headers: {'Authorization': 'Bearer $token'}, // auth header
    );

    final data = res.data; // response json
    if (data is! Map) throw Exception('Invalid delete response'); // guard
    return Map<String, dynamic>.from(data); // return map
  }

  // ------------------------------------------------------------
  // GET /api/messages/unread/by-contact
  // Return unread counts per contact (array or object depending on backend)
  Future<dynamic> getUnreadCounts(String token) async {
    final res = await _fetch.fetch(
      HttpMethod.get, // GET
      '$_base/unread/by-contact', // endpoint
      headers: {'Authorization': 'Bearer $token'}, // auth header
    );

    // backend may return array OR map; we keep it dynamic to mirror RN
    return res.data; // pass-through
  }
}
