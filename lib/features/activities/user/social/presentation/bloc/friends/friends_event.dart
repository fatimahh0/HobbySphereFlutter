import 'package:equatable/equatable.dart';

// All events for FriendsBloc
abstract class FriendsEvent extends Equatable {
  const FriendsEvent();
  @override
  List<Object?> get props => [];
}

// load lists
class LoadAllUsers extends FriendsEvent {
  const LoadAllUsers();
}

class LoadSuggested extends FriendsEvent {
  final int meId;
  const LoadSuggested(this.meId);
  @override
  List<Object?> get props => [meId];
}

// remove one sent request locally (optimistic update)
class RemoveSentLocal extends FriendsEvent {
  final int requestId; // the request id to remove
  const RemoveSentLocal(this.requestId); // ctor
  @override
  List<Object?> get props => [requestId]; // equality
}


class LoadReceived extends FriendsEvent {
  const LoadReceived();
}

class LoadSent extends FriendsEvent {
  const LoadSent();
}

class LoadFriends extends FriendsEvent {
  const LoadFriends();
}

// actions
class SendRequest extends FriendsEvent {
  final int userId;
  const SendRequest(this.userId);
  @override
  List<Object?> get props => [userId];
}

// cancel a SENT request (by requestId)
class CancelRequest extends FriendsEvent {
  final int requestId; // request id, not user id
  const CancelRequest(this.requestId); // store request id
  @override
  List<Object?> get props => [requestId]; // equality
}

class AcceptRequest extends FriendsEvent {
  final int requestId;
  const AcceptRequest(this.requestId);
  @override
  List<Object?> get props => [requestId];
}

class RejectRequest extends FriendsEvent {
  final int requestId;
  const RejectRequest(this.requestId);
  @override
  List<Object?> get props => [requestId];
}

class UnfriendUser extends FriendsEvent {
  final int userId;
  const UnfriendUser(this.userId);
  @override
  List<Object?> get props => [userId];
}

class BlockUser extends FriendsEvent {
  final int userId;
  const BlockUser(this.userId);
  @override
  List<Object?> get props => [userId];
}

class UnblockUser extends FriendsEvent {
  final int userId;
  const UnblockUser(this.userId);
  @override
  List<Object?> get props => [userId];
}
