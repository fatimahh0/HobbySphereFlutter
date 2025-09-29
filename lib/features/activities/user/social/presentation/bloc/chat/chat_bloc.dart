// 🧠 ChatBloc controls a single conversation screen.
import 'dart:io'; // File
import 'package:flutter_bloc/flutter_bloc.dart'; // bloc
import '../../../domain/entities/chat_message.dart'; // entity
import '../../../domain/usecases/chat_usecases.dart'; // UCs
import 'chat_event.dart'; // events
import 'chat_state.dart'; // state

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ConversationUC getConversation; // load
  final SendMessageUC sendMessage; // send
  final MarkReadUC markRead; // read
  final DeleteMessageUC deleteMessage; // delete

  ChatBloc({
    required this.getConversation, // inject
    required this.sendMessage, // inject
    required this.markRead, // inject
    required this.deleteMessage, // inject
  }) : super(ChatState.initial()) {
    on<LoadConversation>(_onLoad); // load conv
    on<SendText>(_onSendText); // send text
    on<SendImage>(_onSendImage); // send image
    on<MarkOneRead>(_onMark); // mark read
    on<DeleteOne>(_onDelete); // delete msg
    on<PushIncoming>(_onPushIncoming); // push in
  }

  Future<void> _safe(
    Future<void> Function() work,
    Emitter<ChatState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, error: null)); // start
      await work(); // do
      emit(state.copyWith(isLoading: false)); // stop
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString())); // error
    }
  }

  Future<void> _onLoad(LoadConversation e, Emitter<ChatState> emit) async =>
      _safe(() async {
        final msgs = await getConversation(e.userId); // fetch
        emit(state.copyWith(withUserId: e.userId, messages: msgs)); // set
      }, emit);

  Future<void> _onSendText(SendText e, Emitter<ChatState> emit) async =>
      _safe(() async {
        final m = await sendMessage(to: e.to, text: e.text); // send
        final copy = List<ChatMessage>.from(state.messages)..add(m); // append
        emit(state.copyWith(messages: copy)); // update
      }, emit);

  Future<void> _onSendImage(SendImage e, Emitter<ChatState> emit) async =>
      _safe(() async {
        final m = await sendMessage(to: e.to, image: File(e.path)); // send
        final copy = List<ChatMessage>.from(state.messages)..add(m); // append
        emit(state.copyWith(messages: copy)); // update
      }, emit);

  Future<void> _onMark(MarkOneRead e, Emitter<ChatState> emit) async =>
      markRead(e.id); // fire-n-forget

  Future<void> _onDelete(DeleteOne e, Emitter<ChatState> emit) async => _safe(
    () async {
      await deleteMessage(e.id); // server
      final copy = state.messages.where((m) => m.id != e.id).toList(); // remove
      emit(state.copyWith(messages: copy)); // update
    },
    emit,
  );

  Future<void> _onPushIncoming(PushIncoming e, Emitter<ChatState> emit) async {
    final copy = List<ChatMessage>.from(state.messages)..add(e.m); // add
    emit(state.copyWith(messages: copy)); // update
  }
}
