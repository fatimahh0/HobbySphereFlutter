// 💡 Chat state.
import 'package:equatable/equatable.dart'; // equality
import '../../../domain/entities/chat_message.dart'; // entity

class ChatState extends Equatable {
  final bool isLoading; // busy flag
  final String? error; // error msg
  final int? withUserId; // current peer id
  final List<ChatMessage> messages; // messages

  const ChatState({
    required this.isLoading, // loading
    required this.error, // error
    required this.withUserId, // peer
    required this.messages, // list
  });

  factory ChatState.initial() => const ChatState(
    isLoading: false, // idle
    error: null, // no error
    withUserId: null, // none
    messages: [], // empty
  );

  ChatState copyWith({
    bool? isLoading, // loading
    String? error, // error
    int? withUserId, // peer
    List<ChatMessage>? messages, // list
  }) => ChatState(
    isLoading: isLoading ?? this.isLoading, // keep/override
    error: error, // override (can be null)
    withUserId: withUserId ?? this.withUserId, // keep/override
    messages: messages ?? this.messages, // keep/override
  );

  @override
  List<Object?> get props => [isLoading, error, withUserId, messages]; // eq
}
