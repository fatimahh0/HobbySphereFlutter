// message_service.dart — add debug logs
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:hobby_sphere/features/activities/user/social/domain/entities/chat_message.dart';
import 'package:hobby_sphere/features/activities/user/social/domain/entities/contact_count.dart';
import 'package:hobby_sphere/services/token_store.dart';

class MessageService {
  final Dio _dio;
  MessageService(String baseUrl) : _dio = Dio(BaseOptions(baseUrl: baseUrl));

  Future<Options> _auth() async {
    final t = await TokenStore.read();
    return Options(headers: {'Authorization': 'Bearer ${t.token ?? ''}'});
  }

  Future<List<ChatMessage>> conversation(int otherId, int meId) async {
    final res = await _dio.get(
      '/api/messages/conversation/$otherId',
      options: await _auth(),
    );

    // 🔎 DEBUG: print first item to check keys
    try {
      // ignore: avoid_print
      print(
        '🚚 conversation[$otherId] sample: ${res.data is List && (res.data as List).isNotEmpty ? (res.data as List).first : res.data}',
      );
    } catch (_) {}

    final list = (res.data as List).cast<dynamic>();
    return list
        .map((e) => ChatMessage.fromMap(e as Map<String, dynamic>, meId))
        .toList();
  }

  Future<ChatMessage> send({
    required int to,
    String? text,
    File? image,
    required int meId,
  }) async {
    final form = FormData();
    if (text != null && text.trim().isNotEmpty) {
      form.fields.add(MapEntry('message', text));
      // some APIs prefer 'text' key too — no harm duplicating
      form.fields.add(MapEntry('text', text));
    }
    if (image != null) {
      final mf = await MultipartFile.fromFile(
        image.path,
        filename: image.uri.pathSegments.isNotEmpty
            ? image.uri.pathSegments.last
            : 'upload.jpg',
      );
      // Try both common field names (servers differ)
      form.files.add(MapEntry('image', mf));
      form.files.add(MapEntry('file', mf));
    }

    final res = await _dio.post(
      '/api/messages/send/$to',
      data: form,
      options: (await _auth()).copyWith(contentType: 'multipart/form-data'),
    );

    // 🔎 DEBUG: print server response after sending
    try {
      // ignore: avoid_print
      print('📨 send response: ${res.data}');
    } catch (_) {}

    return ChatMessage.fromMap(res.data as Map<String, dynamic>, meId);
  }

  Future<void> deleteMessage(int messageId) async {
    await _dio.delete('/api/messages/$messageId', options: await _auth());
  }

  Future<void> markRead(int messageId) async {
    await _dio.patch('/api/messages/$messageId/read', options: await _auth());
  }

  Future<List<ContactCount>> countsByContact() async {
    final res = await _dio.get(
      '/api/messages/count/by-contact',
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
      '/api/messages/unread/by-contact',
      options: await _auth(),
    );
    final data = res.data;
    if (data is List && data.isNotEmpty && data.first is List) {
      return data.map<ContactCount>((e) => ContactCount.fromArray(e)).toList();
    }
    return (data as List).map((e) => ContactCount.fromMap(e)).toList();
  }
}
