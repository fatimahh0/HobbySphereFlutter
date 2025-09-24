import 'package:hobby_sphere/features/activities/user/social/domain/entities/friend_request.dart';
import 'package:hobby_sphere/features/activities/user/social/domain/entities/user_min.dart';
import 'package:hobby_sphere/features/activities/user/social/domain/repositories/friends_repository.dart';


import '../services/friends_service.dart';

// Implementation → delegates to FriendsService
class FriendsRepositoryImpl implements FriendsRepository {
  final FriendsService s; // low-level service
  FriendsRepositoryImpl(this.s);

  @override
  Future<void> accept(int requestId) => s.accept(requestId);

  @override
  Future<List<UserMin>> allUsers() => s.getAllUsers();

  @override
  Future<void> block(int userId) => s.block(userId);

  @override
  Future<void> cancelRequest(int friendId) => s.cancelFriend(friendId);

  @override
  Future<List<UserMin>> friends() => s.getFriends();

  @override
  Future<List<FriendRequestItem>> received() => s.getPending();

  @override
  Future<void> reject(int requestId) => s.reject(requestId);

  @override
  Future<void> sendRequest(int friendId) => s.sendFriend(friendId);

  @override
  Future<List<FriendRequestItem>> sent() => s.getSent();

  @override
  Future<List<UserMin>> suggestedUsers(int meId) => s.getSuggestedUsers(meId);

  @override
  Future<void> unfriend(int userId) => s.unfriend(userId);

  @override
  Future<void> unblock(int userId) => s.unblock(userId);

    @override
  Future<void> cancelSent(int requestId) => s.cancelSentRequest(requestId);
}
