import 'package:equatable/equatable.dart';
import '../../../domain/entities/chat_message.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

// load conversation with selected user
class LoadConversation extends ChatEvent {
  final int userId;
  const LoadConversation(this.userId);
  @override
  List<Object?> get props => [userId];
}

// send text
class SendText extends ChatEvent {
  final int to;
  final String text;
  const SendText(this.to, this.text);
  @override
  List<Object?> get props => [to, text];
}

// send image (path provided)
class SendImage extends ChatEvent {
  final int to;
  final String path;
  const SendImage(this.to, this.path);
  @override
  List<Object?> get props => [to, path];
}

// mark one message read (optional)
class MarkOneRead extends ChatEvent {
  final int id;
  const MarkOneRead(this.id);
  @override
  List<Object?> get props => [id];
}

// delete message
class DeleteOne extends ChatEvent {
  final int id;
  const DeleteOne(this.id);
  @override
  List<Object?> get props => [id];
}

// push a new message from server (future socket)
class PushIncoming extends ChatEvent {
  final ChatMessage m;
  const PushIncoming(this.m);
  @override
  List<Object?> get props => [m];
}
