// 💡 Chat state — Flutter 3.35.x
// Small, equatable, immutable.

import 'package:equatable/equatable.dart'; // equality
import '../../../domain/entities/chat_message.dart'; // entity

class ChatState extends Equatable {
  final bool isLoading; // busy flag
  final String? error; // error text
  final int? withUserId; // current peer
  final List<ChatMessage> messages; // list

  const ChatState({
    required this.isLoading, // loading
    required this.error, // error
    required this.withUserId, // peer
    required this.messages, // list
  });

  // initial state
  factory ChatState.initial() => const ChatState(
    isLoading: false, // idle
    error: null, // none
    withUserId: null, // none
    messages: <ChatMessage>[], // empty
  );

  // copy with overrides
  ChatState copyWith({
    bool? isLoading, // new loading
    String? error, // new error
    int? withUserId, // new peer
    List<ChatMessage>? messages, // new list
  }) => ChatState(
    isLoading: isLoading ?? this.isLoading, // keep
    error: error, // override (can be null)
    withUserId: withUserId ?? this.withUserId, // keep
    messages: messages ?? this.messages, // keep
  );

  @override
  List<Object?> get props => [isLoading, error, withUserId, messages]; // eq
}
