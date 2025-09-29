// 🏗️ Chat repository → delegates to service.
import '../../domain/repositories/chat_repository.dart'; // contract
import '../../domain/entities/chat_message.dart'; // entity
import '../../domain/entities/contact_count.dart'; // entity
import '../services/message_service.dart'; // service

class ChatRepositoryImpl implements ChatRepository {
  final MessageService s; // service
  final int meId; // my id for isMine

  ChatRepositoryImpl(this.s, {required this.meId}); // ctor

  @override
  Future<List<ContactCount>> countsByContact() => s.countsByContact(); // forward

  @override
  Future<ChatMessage> send({required int receiverId, String? message, image}) =>
      s.send(to: receiverId, text: message, image: image, meId: meId); // forward

  @override
  Future<List<ChatMessage>> conversation(int userId) =>
      s.conversation(userId, meId); // forward

  @override
  Future<void> deleteMessage(int messageId) => s.deleteMessage(messageId); // forward

  @override
  Future<void> markRead(int messageId) => s.markRead(messageId); // forward

  @override
  Future<List<ContactCount>> unreadByContact() => s.unreadByContact(); // forward
}
