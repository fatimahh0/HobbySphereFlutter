import 'package:equatable/equatable.dart';
import '../../../domain/entities/chat_message.dart';

class ChatState extends Equatable {
  final bool isLoading; // loading flag
  final String? error; // error message
  final int? withUserId; // current peer id
  final List<ChatMessage> messages; // conversation messages

  const ChatState({
    required this.isLoading,
    required this.error,
    required this.withUserId,
    required this.messages,
  });

  factory ChatState.initial() => const ChatState(
    isLoading: false,
    error: null,
    withUserId: null,
    messages: [],
  );

  ChatState copyWith({
    bool? isLoading,
    String? error,
    int? withUserId,
    List<ChatMessage>? messages,
  }) => ChatState(
    isLoading: isLoading ?? this.isLoading,
    error: error,
    withUserId: withUserId ?? this.withUserId,
    messages: messages ?? this.messages,
  );

  @override
  List<Object?> get props => [isLoading, error, withUserId, messages];
}
