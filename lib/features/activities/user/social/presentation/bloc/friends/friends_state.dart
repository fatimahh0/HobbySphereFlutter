import 'package:equatable/equatable.dart';
import '../../../domain/entities/friend_request.dart';
import '../../../domain/entities/user_min.dart';

// State holds the three lists + busy/error flags.
class FriendsState extends Equatable {
  final bool isLoading; // global loading
  final String? error; // error message if any
  final List<UserMin> all; // "All Users"
  final List<UserMin> suggested; // "Suggested Users"
  final List<FriendRequestItem> received; // incoming requests
  final List<FriendRequestItem> sent; // outgoing requests
  final List<UserMin> friends; // my friends

  const FriendsState({
    required this.isLoading,
    required this.error,
    required this.all,
    required this.suggested,
    required this.received,
    required this.sent,
    required this.friends,
  });

  factory FriendsState.initial() => const FriendsState(
    isLoading: false,
    error: null,
    all: [],
    suggested: [],
    received: [],
    sent: [],
    friends: [],
  );

  FriendsState copyWith({
    bool? isLoading,
    String? error,
    List<UserMin>? all,
    List<UserMin>? suggested,
    List<FriendRequestItem>? received,
    List<FriendRequestItem>? sent,
    List<UserMin>? friends,
  }) => FriendsState(
    isLoading: isLoading ?? this.isLoading,
    error: error,
    all: all ?? this.all,
    suggested: suggested ?? this.suggested,
    received: received ?? this.received,
    sent: sent ?? this.sent,
    friends: friends ?? this.friends,
  );

  @override
  List<Object?> get props => [
    isLoading,
    error,
    all,
    suggested,
    received,
    sent,
    friends,
  ];
}
