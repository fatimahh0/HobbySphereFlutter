// ⚡ Chat events — Flutter 3.35.x
// Clean, positional constructors. Equatable for cheap diffs.

import 'package:equatable/equatable.dart'; // equality
import '../../../domain/entities/chat_message.dart'; // entity

// base event (equatable)
abstract class ChatEvent extends Equatable {
  const ChatEvent(); // base
  @override
  List<Object?> get props => []; // default
}

// load conversation with one user
class LoadConversation extends ChatEvent {
  final int userId; // peer id
  const LoadConversation(this.userId); // ctor
  @override
  List<Object?> get props => [userId]; // eq
}

// send plain text
class SendText extends ChatEvent {
  final int to; // receiver
  final String text; // body
  const SendText(this.to, this.text); // ctor
  @override
  List<Object?> get props => [to, text]; // eq
}

// send image from local file path (XFile.path)
class SendImage extends ChatEvent {
  final int to; // receiver
  final String path; // local path
  const SendImage(this.to, this.path); // ctor
  @override
  List<Object?> get props => [to, path]; // eq
}

// mark one as read
class MarkOneRead extends ChatEvent {
  final int id; // message id
  const MarkOneRead(this.id); // ctor
  @override
  List<Object?> get props => [id]; // eq
}

// delete one message
class DeleteOne extends ChatEvent {
  final int id; // message id
  const DeleteOne(this.id); // ctor
  @override
  List<Object?> get props => [id]; // eq
}

// push incoming (WS/FCM)
class PushIncoming extends ChatEvent {
  final ChatMessage m; // payload
  const PushIncoming(this.m); // ctor
  @override
  List<Object?> get props => [m]; // eq
}
