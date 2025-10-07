// Flutter 3.35.x — clean and stable.
// Sends text and/or one image file without reusing MultipartFile.
// Each line has a short comment.

import 'dart:io'; // File
import 'package:dio/dio.dart'; // HTTP + FormData
import 'package:hobby_sphere/features/activities/user/social/domain/entities/chat_message.dart'; // entity
import 'package:hobby_sphere/features/activities/user/social/domain/entities/contact_count.dart'; // counts
import 'package:hobby_sphere/services/token_store.dart'; // token read

class MessageService {
  final Dio _dio; // http client

  MessageService(String baseUrl)
    : _dio = Dio(BaseOptions(baseUrl: baseUrl)); // base URL

  Future<Options> _auth() async {
    final t = await TokenStore.read(); // load token
    return Options(
      headers: {'Authorization': 'Bearer ${t.token ?? ''}'},
    ); // header
  }

  // ---------- read chat ----------

  Future<List<ChatMessage>> conversation(int otherId, int meId) async {
    final res = await _dio.get(
      '/api/messages/conversation/$otherId', // endpoint
      options: await _auth(), // auth
    );
    final list = (res.data as List).cast<dynamic>(); // cast list
    return list
        .map((e) => ChatMessage.fromMap(e as Map<String, dynamic>, meId)) // map
        .toList(); // done
  }

  // ---------- send text / image (no input blocking) ----------

  Future<ChatMessage> send({
    required int to, // receiver id
    String? text, // optional text
    File? image, // optional image file
    required int meId, // my id (used by fromMap for isMine)
  }) async {
    final form = FormData(); // fresh form each call

    // add text once if present
    if (text != null && text.trim().isNotEmpty) {
      form.fields.add(MapEntry('message', text.trim())); // server "message"
    }

    // add image once if present — IMPORTANT: only ONE key to avoid finalize()
    if (image != null) {
      final mf = await MultipartFile.fromFile(
        image.path, // local path
        filename: image.uri.pathSegments.isNotEmpty
            ? image.uri.pathSegments.last
            : 'upload.jpg', // name
      );
      form.files.add(MapEntry('image', mf)); // one field only
    }

    // post multipart form (Dio sets content-type automatically)
    final res = await _dio.post(
      '/api/messages/send/$to', // endpoint
      data: form, // multipart
      options: await _auth(), // auth
    );

    // parse back to entity
    return ChatMessage.fromMap(
      res.data as Map<String, dynamic>,
      meId,
    ); // entity
  }

  // ---------- misc APIs ----------

  Future<void> deleteMessage(int messageId) async {
    await _dio.delete(
      '/api/messages/$messageId',
      options: await _auth(),
    ); // delete
  }

  Future<void> markRead(int messageId) async {
    await _dio.patch(
      '/api/messages/$messageId/read',
      options: await _auth(),
    ); // read
  }

  Future<List<ContactCount>> countsByContact() async {
    final res = await _dio.get(
      '/api/messages/count/by-contact',
      options: await _auth(),
    ); // get
    final data = res.data; // payload
    if (data is List && data.isNotEmpty && data.first is List) {
      return data
          .map<ContactCount>((e) => ContactCount.fromArray(e))
          .toList(); // tuple
    }
    return (data as List).map((e) => ContactCount.fromMap(e)).toList(); // map
  }

  Future<List<ContactCount>> unreadByContact() async {
    final res = await _dio.get(
      '/api/messages/unread/by-contact',
      options: await _auth(),
    ); // get
    final data = res.data; // payload
    if (data is List && data.isNotEmpty && data.first is List) {
      return data
          .map<ContactCount>((e) => ContactCount.fromArray(e))
          .toList(); // tuple
    }
    return (data as List).map((e) => ContactCount.fromMap(e)).toList(); // map
  }
}
