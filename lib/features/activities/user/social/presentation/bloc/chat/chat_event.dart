// ⚡ Chat events.
import 'package:equatable/equatable.dart'; // equality
import '../../../domain/entities/chat_message.dart'; // entity

abstract class ChatEvent extends Equatable {
  const ChatEvent(); // base
  @override
  List<Object?> get props => []; // none
}

class LoadConversation extends ChatEvent {
  final int userId; // other id
  const LoadConversation(this.userId); // ctor
  @override
  List<Object?> get props => [userId]; // eq
}

class SendText extends ChatEvent {
  final int to; // receiver
  final String text; // message
  const SendText(this.to, this.text); // ctor
  @override
  List<Object?> get props => [to, text]; // eq
}

class SendImage extends ChatEvent {
  final int to; // receiver
  final String path; // file path
  const SendImage(this.to, this.path); // ctor
  @override
  List<Object?> get props => [to, path]; // eq
}

class MarkOneRead extends ChatEvent {
  final int id; // message id
  const MarkOneRead(this.id); // ctor
  @override
  List<Object?> get props => [id]; // eq
}

class DeleteOne extends ChatEvent {
  final int id; // message id
  const DeleteOne(this.id); // ctor
  @override
  List<Object?> get props => [id]; // eq
}

class PushIncoming extends ChatEvent {
  final ChatMessage m; // new message
  const PushIncoming(this.m); // ctor
  @override
  List<Object?> get props => [m]; // eq
}
