import '../entities/chat_message.dart';
import '../entities/contact_count.dart';

abstract class ChatRepository {
  Future<List<ChatMessage>> conversation(
    int userId,
  ); // GET /api/messages/conversation/{userId}
  Future<ChatMessage> send({
    required int receiverId,
    String? message,
    dynamic image,
  }); // POST /api/messages/send/{id} (multipart)
  Future<void> deleteMessage(int messageId); // DELETE /api/messages/{id}
  Future<void> markRead(int messageId); // PATCH /api/messages/{id}/read
  Future<List<ContactCount>>
  countsByContact(); // GET /api/messages/count/by-contact
  Future<List<ContactCount>>
  unreadByContact(); // GET /api/messages/unread/by-contact
}
