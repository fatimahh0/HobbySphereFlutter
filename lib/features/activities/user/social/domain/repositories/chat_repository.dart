// 📦 Chat repository contract (used by UCs/Bloc).
import '../entities/chat_message.dart';
import '../entities/contact_count.dart';

abstract class ChatRepository {
  Future<List<ChatMessage>> conversation(int userId); // GET conv
  Future<ChatMessage> send({
    required int receiverId, // to
    String? message, // text
    dynamic image, // file
  }); // POST send
  Future<void> deleteMessage(int messageId); // DELETE
  Future<void> markRead(int messageId); // PATCH read
  Future<List<ContactCount>> countsByContact(); // counts
  Future<List<ContactCount>> unreadByContact(); // unread
}
