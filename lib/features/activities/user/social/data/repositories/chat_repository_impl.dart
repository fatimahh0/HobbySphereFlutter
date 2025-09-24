import 'package:hobby_sphere/features/activities/user/social/domain/entities/chat_message.dart';
import 'package:hobby_sphere/features/activities/user/social/domain/entities/contact_count.dart';
import 'package:hobby_sphere/features/activities/user/social/domain/repositories/chat_repository.dart';

import '../services/message_service.dart';

// Implementation → delegates to MessageService
class ChatRepositoryImpl implements ChatRepository {
  final MessageService s;
  final int meId; // current user id for "isMine" mapping

  ChatRepositoryImpl(this.s, {required this.meId});

  @override
  Future<List<ContactCount>> countsByContact() => s.countsByContact();

  @override
  Future<ChatMessage> send({required int receiverId, String? message, image}) =>
      s.send(to: receiverId, text: message, image: image, meId: meId);

  @override
  Future<List<ChatMessage>> conversation(int userId) =>
      s.conversation(userId, meId);

  @override
  Future<void> deleteMessage(int messageId) => s.deleteMessage(messageId);

  @override
  Future<void> markRead(int messageId) => s.markRead(messageId);

  @override
  Future<List<ContactCount>> unreadByContact() => s.unreadByContact();
}
