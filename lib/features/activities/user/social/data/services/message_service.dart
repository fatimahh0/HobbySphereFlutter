// Flutter 3.35.x — MessageService with ownerProjectLinkId injection
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:hobby_sphere/config/env.dart'; // <-- for OWNER_PROJECT_LINK_ID
import 'package:hobby_sphere/features/activities/user/social/domain/entities/chat_message.dart';
import 'package:hobby_sphere/features/activities/user/social/domain/entities/contact_count.dart';
import 'package:hobby_sphere/features/authentication/login&register/data/services/token_store.dart';

class MessageService {
  final Dio _dio;

  MessageService(String baseUrl) : _dio = Dio(BaseOptions(baseUrl: baseUrl));

  // ---- Owner/Tenant helpers ----
  dynamic get _oplId {
    final raw = (Env.ownerProjectLinkId).trim();
    assert(raw.isNotEmpty, 'OWNER_PROJECT_LINK_ID is required.');
    return int.tryParse(raw) ?? raw;
  }

  // Append ownerProjectLinkId to any path (keeps existing query params)
  String _withOwnerQuery(String path) {
    final uri = Uri.parse(path);
    final qp = Map<String, String>.from(uri.queryParameters)
      ..['ownerProjectLinkId'] = _oplId.toString();
    return uri.replace(queryParameters: qp).toString();
  }

  // Add ownerProjectLinkId to existing FormData
  FormData _addOwnerToForm(FormData form) {
    form.fields.add(MapEntry('ownerProjectLinkId', _oplId.toString()));
    return form;
  }

  Future<Options> _auth() async {
    final t = await TokenStore.read();
    final token = (t.token ?? '').trim();
    final bearer = token.startsWith('Bearer ') ? token : 'Bearer $token';
    return Options(headers: {'Authorization': bearer});
  }

  // ---------- read chat ----------

  Future<List<ChatMessage>> conversation(int otherId, int meId) async {
    final res = await _dio.get(
      _withOwnerQuery('/messages/conversation/$otherId'),
      options: await _auth(),
    );
    final list = (res.data as List).cast<dynamic>();
    return list
        .map((e) => ChatMessage.fromMap(e as Map<String, dynamic>, meId))
        .toList();
  }

  // ---------- send text / image ----------

  Future<ChatMessage> send({
    required int to,
    String? text,
    File? image,
    required int meId,
  }) async {
    final form = FormData();

    if (text != null && text.trim().isNotEmpty) {
      form.fields.add(MapEntry('message', text.trim()));
    }

    if (image != null) {
      final mf = await MultipartFile.fromFile(
        image.path,
        filename: image.uri.pathSegments.isNotEmpty
            ? image.uri.pathSegments.last
            : 'upload.jpg',
      );
      form.files.add(MapEntry('image', mf));
    }

    final res = await _dio.post(
      '/messages/send/$to',
      data: _addOwnerToForm(form), // <-- inject owner in body
      options: await _auth(),
    );

    return ChatMessage.fromMap(res.data as Map<String, dynamic>, meId);
  }

  // ---------- misc APIs ----------

  Future<void> deleteMessage(int messageId) async {
    await _dio.delete(
      _withOwnerQuery('/messages/$messageId'),
      options: await _auth(),
    );
  }

  Future<void> markRead(int messageId) async {
    await _dio.patch(
      _withOwnerQuery('/messages/$messageId/read'),
      options: await _auth(),
    );
  }

  Future<List<ContactCount>> countsByContact() async {
    final res = await _dio.get(
      _withOwnerQuery('/messages/count/by-contact'),
      options: await _auth(),
    );
    final data = res.data;
    if (data is List && data.isNotEmpty && data.first is List) {
      return data.map<ContactCount>((e) => ContactCount.fromArray(e)).toList();
    }
    return (data as List).map((e) => ContactCount.fromMap(e)).toList();
  }

  Future<List<ContactCount>> unreadByContact() async {
    final res = await _dio.get(
      _withOwnerQuery('/messages/unread/by-contact'),
      options: await _auth(),
    );
    final data = res.data;
    if (data is List && data.isNotEmpty && data.first is List) {
      return data.map<ContactCount>((e) => ContactCount.fromArray(e)).toList();
    }
    return (data as List).map((e) => ContactCount.fromMap(e)).toList();
  }
}
