import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/chat_message.dart';
import '../../../domain/usecases/chat_usecases.dart';
import 'chat_event.dart';
import 'chat_state.dart';

// Handles one conversation screen.
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ConversationUC getConversation;
  final SendMessageUC sendMessage;
  final MarkReadUC markRead;
  final DeleteMessageUC deleteMessage;

  ChatBloc({
    required this.getConversation,
    required this.sendMessage,
    required this.markRead,
    required this.deleteMessage,
  }) : super(ChatState.initial()) {
    on<LoadConversation>(_onLoad);
    on<SendText>(_onSendText);
    on<SendImage>(_onSendImage);
    on<MarkOneRead>(_onMark);
    on<DeleteOne>(_onDelete);
    on<PushIncoming>(_onPushIncoming);
  }

  Future<void> _safe(
    Future<void> Function() work,
    Emitter<ChatState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, error: null));
      await work();
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onLoad(LoadConversation e, Emitter<ChatState> emit) async =>
      _safe(() async {
        final msgs = await getConversation(e.userId); // load from repo
        emit(
          state.copyWith(withUserId: e.userId, messages: msgs),
        ); // put in state
      }, emit);

  Future<void> _onSendText(SendText e, Emitter<ChatState> emit) async =>
      _safe(() async {
        final m = await sendMessage(to: e.to, text: e.text); // send text
        final copy = List<ChatMessage>.from(state.messages)..add(m); // append
        emit(state.copyWith(messages: copy)); // update list
      }, emit);

  Future<void> _onSendImage(SendImage e, Emitter<ChatState> emit) async =>
      _safe(() async {
        final m = await sendMessage(
          to: e.to,
          image: File(e.path),
        ); // send image
        final copy = List<ChatMessage>.from(state.messages)..add(m);
        emit(state.copyWith(messages: copy));
      }, emit);

  Future<void> _onMark(MarkOneRead e, Emitter<ChatState> emit) async =>
      markRead(e.id); // fire & forget

  Future<void> _onDelete(DeleteOne e, Emitter<ChatState> emit) async =>
      _safe(() async {
        await deleteMessage(e.id); // delete server
        final copy = state.messages
            .where((m) => m.id != e.id)
            .toList(); // remove local
        emit(state.copyWith(messages: copy)); // update
      }, emit);

  Future<void> _onPushIncoming(PushIncoming e, Emitter<ChatState> emit) async {
    final copy = List<ChatMessage>.from(state.messages)
      ..add(e.m); // append push
    emit(state.copyWith(messages: copy));
  }
}
