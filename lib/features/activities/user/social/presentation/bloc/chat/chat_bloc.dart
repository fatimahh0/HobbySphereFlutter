// 🧠 ChatBloc — Flutter 3.35.x
// Robust optimistic UI with pending → sent replacement.
// Always emits a NEW list instance so UI refreshes properly.

import 'dart:io'; // File
import 'package:flutter_bloc/flutter_bloc.dart'; // bloc

import '../../../domain/entities/chat_message.dart'; // entity
import '../../../domain/usecases/chat_usecases.dart'; // use cases
import 'chat_event.dart'; // events
import 'chat_state.dart'; // state

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final int myId; // current user id
  final ConversationUC getConversation; // load uc
  final SendMessageUC sendMessage; // send uc
  final MarkReadUC markRead; // read uc
  final DeleteMessageUC deleteMessage; // delete uc

  int _tempId = -1; // negative ids for pending

  ChatBloc({
    required this.myId, // my id
    required this.getConversation, // uc
    required this.sendMessage, // uc
    required this.markRead, // uc
    required this.deleteMessage, // uc
  }) : super(ChatState.initial()) {
    on<LoadConversation>(_onLoad); // load
    on<SendText>(_onSendText); // text
    on<SendImage>(_onSendImage); // image
    on<MarkOneRead>(_onMark); // read
    on<DeleteOne>(_onDelete); // delete
    on<PushIncoming>(_onPushIncoming); // push
  }

  // small wrapping helper to show loading during heavy ops
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

  // ========== LOAD ==========

  Future<void> _onLoad(LoadConversation e, Emitter<ChatState> emit) async =>
      _safe(() async {
        final msgs = await getConversation(e.userId); // fetch
        // emit new list instance
        emit(
          state.copyWith(
            withUserId: e.userId, // set peer
            messages: List<ChatMessage>.unmodifiable(msgs), // freeze list
            error: null, // clear error
          ),
        );
      }, emit);

  // ========== SEND TEXT ==========

  Future<void> _onSendText(SendText e, Emitter<ChatState> emit) async {
    // 1) build pending message
    final temp = ChatMessage(
      id: _tempId--, // negative id
      senderId: myId, // me
      receiverId: e.to, // peer
      text: e.text, // body
      imageUrl: null, // none
      localImagePath: null, // none
      sentAt: DateTime.now(), // now
      isMine: true, // my side
      isRead: false, // not read
    );

    // 2) emit list + pending (NEW instance)
    final appended = List<ChatMessage>.from(state.messages)..add(temp); // copy
    emit(
      state.copyWith(messages: List<ChatMessage>.unmodifiable(appended)),
    ); // emit

    try {
      // 3) send to server
      final saved = await sendMessage(to: e.to, text: e.text); // api
      // 4) replace pending
      _replacePending(
        emit: emit,
        tempId: temp.id,
        saved: saved,
        clearLocal: false,
      ); // no local
    } catch (err) {
      // 5) remove pending on error
      final copy = List<ChatMessage>.from(state.messages)
        ..removeWhere((m) => m.id == temp.id); // drop
      emit(
        state.copyWith(
          messages: List<ChatMessage>.unmodifiable(copy), // new list
          error: err.toString(), // error
        ),
      );
    }
  }

  // ========== SEND IMAGE ==========

  Future<void> _onSendImage(SendImage e, Emitter<ChatState> emit) async {
    // 1) build pending with local preview
    final temp = ChatMessage(
      id: _tempId--, // negative id
      senderId: myId, // me
      receiverId: e.to, // peer
      text: null, // none
      imageUrl: null, // none
      localImagePath: e.path, // local preview
      sentAt: DateTime.now(), // now
      isMine: true, // my side
      isRead: false, // not read
    );

    // 2) append pending (NEW instance)
    final appended = List<ChatMessage>.from(state.messages)..add(temp); // copy
    emit(
      state.copyWith(messages: List<ChatMessage>.unmodifiable(appended)),
    ); // emit

    try {
      // 3) send with file to server
      final saved = await sendMessage(to: e.to, image: File(e.path)); // api
      // 4) replace + clear local preview
      _replacePending(
        emit: emit,
        tempId: temp.id,
        saved: saved,
        clearLocal: true,
      ); // clear local
    } catch (err) {
      // 5) drop pending on error
      final copy = List<ChatMessage>.from(state.messages)
        ..removeWhere((m) => m.id == temp.id); // drop
      emit(
        state.copyWith(
          messages: List<ChatMessage>.unmodifiable(copy), // new list
          error: err.toString(), // error
        ),
      );
    }
  }

  // helper: replace the pending item by server message
  void _replacePending({
    required Emitter<ChatState> emit, // emitter
    required int tempId, // negative id to find
    required ChatMessage saved, // server message
    required bool clearLocal, // clear local preview?
  }) {
    // copy current list (do NOT mutate original)
    final List<ChatMessage> copy = List<ChatMessage>.from(state.messages);
    // find temp item
    final int idx = copy.indexWhere((m) => m.id == tempId);
    if (idx == -1) {
      // not found: append server item (safety)
      copy.add(saved);
    } else {
      // replace with merged message (keep text if server omitted)
      final current = copy[idx]; // old
      final replacement = current.copyWith(
        id: saved.id, // real id
        text: saved.text ?? current.text, // keep text
        imageUrl: saved.imageUrl ?? current.imageUrl, // remote url
        localImagePath: clearLocal ? null : current.localImagePath, // clear?
        sentAt: saved.sentAt, // server time
        isRead: saved.isRead, // read state
      );
      copy[idx] = replacement; // set
    }
    // emit NEW list (unmodifiable so no accidental mutation)
    emit(
      state.copyWith(messages: List<ChatMessage>.unmodifiable(copy)),
    ); // emit
  }

  // ========== MARK READ ==========

  Future<void> _onMark(MarkOneRead e, Emitter<ChatState> emit) async {
    // fire-and-forget; backend will drive receipts
    await markRead(e.id); // api
  }

  // ========== DELETE ==========

  Future<void> _onDelete(DeleteOne e, Emitter<ChatState> emit) async => _safe(
    () async {
      await deleteMessage(e.id); // api
      final copy = state.messages.where((m) => m.id != e.id).toList(); // filter
      emit(
        state.copyWith(messages: List<ChatMessage>.unmodifiable(copy)),
      ); // emit
    },
    emit,
  );

  // ========== INCOMING PUSH ==========

  Future<void> _onPushIncoming(PushIncoming e, Emitter<ChatState> emit) async {
    final copy = List<ChatMessage>.from(state.messages)..add(e.m); // append
    emit(
      state.copyWith(messages: List<ChatMessage>.unmodifiable(copy)),
    ); // emit
  }
}
