import 'dart:io'; // for File
import 'package:dio/dio.dart';
import 'package:hobby_sphere/features/activities/user/social/domain/entities/chat_message.dart';
import 'package:hobby_sphere/features/activities/user/social/domain/entities/contact_count.dart';
import 'package:hobby_sphere/services/token_store.dart';

// Low-level chat service for /api/messages*
class MessageService {
  final Dio _dio;

  MessageService(String baseUrl) : _dio = Dio(BaseOptions(baseUrl: baseUrl));

  Future<Options> _auth() async {
    final t = await TokenStore.read();
    return Options(headers: {'Authorization': 'Bearer ${t.token ?? ''}'});
  }

  // GET /api/messages/conversation/{userId} → List<ChatMessageDto>
  Future<List<ChatMessage>> conversation(int otherId, int meId) async {
    final res = await _dio.get(
      '/api/messages/conversation/$otherId',
      options: await _auth(),
    );
    final list = (res.data as List).cast<dynamic>();
    return list
        .map((e) => ChatMessage.fromMap(e as Map<String, dynamic>, meId))
        .toList();
  }

  // POST /api/messages/send/{receiverId} (multipart)
  Future<ChatMessage> send({
    required int to,
    String? text,
    File? image,
    required int meId,
  }) async {
    final form = FormData(); // create multi-part form
    if (text != null && text.trim().isNotEmpty) {
      // add message if any
      form.fields.add(MapEntry('message', text));
    }
    if (image != null) {
      // attach image file if any
      form.files.add(
        MapEntry(
          'image',
          await MultipartFile.fromFile(
            image.path,
            filename: image.uri.pathSegments.last,
          ),
        ),
      );
    }
    final res = await _dio.post(
      '/api/messages/send/$to',
      data: form,
      options: (await _auth()).copyWith(contentType: 'multipart/form-data'),
    );
    return ChatMessage.fromMap(
      res.data as Map<String, dynamic>,
      meId,
    ); // map dto
  }

  // DELETE /api/messages/{id}
  Future<void> deleteMessage(int messageId) async {
    await _dio.delete('/api/messages/$messageId', options: await _auth());
  }

  // PATCH /api/messages/{id}/read
  Future<void> markRead(int messageId) async {
    await _dio.patch('/api/messages/$messageId/read', options: await _auth());
  }

  // GET /api/messages/count/by-contact → [{contactId,count}]
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

  // GET /api/messages/unread/by-contact
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
