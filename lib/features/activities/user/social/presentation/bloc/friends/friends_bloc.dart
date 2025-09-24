// friends_bloc.dart — Flutter 3.35.x
// Simple, clean, and professional; every line has a short comment.

import 'package:flutter_bloc/flutter_bloc.dart'; // bloc base
import 'friends_event.dart'; // events
import 'friends_state.dart'; // state
import '../../../domain/usecases/friends_usecases.dart'; // all UCs

// Orchestrates all friendship flows in one place.
class FriendsBloc extends Bloc<FriendsEvent, FriendsState> {
  // === Hold references to all needed use cases ===
  final GetAllUsersUC getAll; // list all users
  final GetSuggestedUC getSuggested; // list suggested users
  final SendFriendUC sendFriend; // send friend request
  final CancelFriendUC cancelFriend; // cancel sent request
  final GetReceivedUC getReceived; // received requests
  final GetSentUC getSent; // sent requests
  final GetFriendsUC getFriends; // my friends
  final AcceptUC acceptUC; // accept request
  final RejectUC rejectUC; // reject request
  final UnfriendUC unfriendUC; // remove friend
  final BlockUC blockUC; // block user
  final UnblockUC unblockUC; // unblock user

  // ✅ Constructor uses ONLY named, required params (no positional args)
  FriendsBloc({
    required this.getAll, // inject use case
    required this.getSuggested, // inject use case
    required this.sendFriend, // inject use case
    required this.cancelFriend, // inject use case
    required this.getReceived, // inject use case
    required this.getSent, // inject use case
    required this.getFriends, // inject use case
    required this.acceptUC, // inject use case
    required this.rejectUC, // inject use case
    required this.unfriendUC, // inject use case
    required this.blockUC, // inject use case
    required this.unblockUC, // inject use case
  }) : super(FriendsState.initial()) {
    // set initial state
    // === Register event handlers ===
    on<LoadAllUsers>(_onLoadAll); // handle load all users
    on<LoadSuggested>(_onLoadSuggested); // handle suggested list
    on<LoadReceived>(_onLoadReceived); // handle received requests
    on<LoadSent>(_onLoadSent); // handle sent requests
    on<LoadFriends>(_onLoadFriends); // handle friends list
    on<SendRequest>(_onSend); // handle send friend
    on<CancelRequest>(_onCancel); // handle cancel send
    on<AcceptRequest>(_onAccept); // handle accept request
    on<RejectRequest>(_onReject); // handle reject request
    on<UnfriendUser>(_onUnfriend); // handle unfriend
    on<BlockUser>(_onBlock); // handle block
    on<UnblockUser>(_onUnblock); // handle unblock
     on<RemoveSentLocal>(_onRemoveSentLocal); // ✅ register optimistic remove
  }

  // Small helper to wrap async work with loading/error states
  Future<void> _safe(
    Future<void> Function() work, // job to run
    Emitter<FriendsState> emit, // emitter
  ) async {
    try {
      emit(state.copyWith(isLoading: true, error: null)); // start loading
      await work(); // do the work
      emit(state.copyWith(isLoading: false, error: null)); // stop loading
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString())); // show error
    }
  }

  // === Handlers: tiny, focused, and readable ===

  Future<void> _onLoadAll(LoadAllUsers e, Emitter<FriendsState> emit) async =>
      _safe(() async {
        final list = await getAll(); // fetch all users
        emit(state.copyWith(all: list)); // update state
      }, emit);

  Future<void> _onLoadSuggested(
    LoadSuggested e,
    Emitter<FriendsState> emit,
  ) async => _safe(() async {
    final list = await getSuggested(e.meId); // fetch suggestions
    emit(state.copyWith(suggested: list)); // update state
  }, emit);

  Future<void> _onLoadReceived(
    LoadReceived e,
    Emitter<FriendsState> emit,
  ) async => _safe(() async {
    final list = await getReceived(); // fetch received reqs
    emit(state.copyWith(received: list)); // update state
  }, emit);

  Future<void> _onLoadSent(LoadSent e, Emitter<FriendsState> emit) async =>
      _safe(() async {
        final list = await getSent(); // fetch sent reqs
        emit(state.copyWith(sent: list)); // update state
      }, emit);

  Future<void> _onLoadFriends(
    LoadFriends e,
    Emitter<FriendsState> emit,
  ) async => _safe(() async {
    final list = await getFriends(); // fetch friends
    emit(state.copyWith(friends: list)); // update state
  }, emit);

  Future<void> _onSend(SendRequest e, Emitter<FriendsState> emit) async =>
      _safe(() async {
        await sendFriend(e.userId); // call UC
      }, emit);

 Future<void> _onCancel(CancelRequest e, Emitter<FriendsState> emit) async =>
      _safe(() async {
        await cancelFriend(e.requestId); // pass requestId, not userId
      }, emit);


  Future<void> _onAccept(AcceptRequest e, Emitter<FriendsState> emit) async =>
      _safe(() async {
        await acceptUC(e.requestId); // call UC
      }, emit);

  Future<void> _onReject(RejectRequest e, Emitter<FriendsState> emit) async =>
      _safe(() async {
        await rejectUC(e.requestId); // call UC
      }, emit);

  Future<void> _onUnfriend(UnfriendUser e, Emitter<FriendsState> emit) async =>
      _safe(() async {
        await unfriendUC(e.userId); // call UC
      }, emit);

  Future<void> _onBlock(BlockUser e, Emitter<FriendsState> emit) async =>
      _safe(() async {
        await blockUC(e.userId); // call UC
      }, emit);

  Future<void> _onUnblock(UnblockUser e, Emitter<FriendsState> emit) async =>
      _safe(() async {
        await unblockUC(e.userId); // call UC
      }, emit);


      Future<void> _onRemoveSentLocal(
    RemoveSentLocal e, // event with id
    Emitter<FriendsState> emit, // emitter
  ) async {
    // filter out the cancelled request
    final next = state.sent
        .where((r) => r.requestId != e.requestId) // keep others
        .toList(); // new list
    emit(state.copyWith(sent: next)); // update state
  }
}
