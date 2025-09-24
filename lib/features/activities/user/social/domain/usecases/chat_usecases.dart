import '../entities/chat_message.dart';
import '../entities/contact_count.dart';
import '../repositories/chat_repository.dart';

class ConversationUC {
  final ChatRepository r;
  ConversationUC(this.r);
  Future<List<ChatMessage>> call(int id) => r.conversation(id);
}

class SendMessageUC {
  final ChatRepository r;
  SendMessageUC(this.r);
  Future<ChatMessage> call({required int to, String? text, dynamic image}) =>
      r.send(receiverId: to, message: text, image: image);
}

class CountsByContactUC {
  final ChatRepository r;
  CountsByContactUC(this.r);
  Future<List<ContactCount>> call() => r.countsByContact();
}

class UnreadByContactUC {
  final ChatRepository r;
  UnreadByContactUC(this.r);
  Future<List<ContactCount>> call() => r.unreadByContact();
}

class MarkReadUC {
  final ChatRepository r;
  MarkReadUC(this.r);
  Future<void> call(int id) => r.markRead(id);
}

class DeleteMessageUC {
  final ChatRepository r;
  DeleteMessageUC(this.r);
  Future<void> call(int id) => r.deleteMessage(id);
}
