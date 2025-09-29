// 🏗️ Friends repository → delegates to service.
import '../../domain/repositories/friends_repository.dart'; // contract
import '../../domain/entities/user_min.dart'; // entity
import '../../domain/entities/friend_request.dart'; // entity
import '../services/friends_service.dart'; // service

class FriendsRepositoryImpl implements FriendsRepository {
  final FriendsService s; // service
  FriendsRepositoryImpl(this.s); // ctor

  @override
  Future<void> accept(int requestId) => s.accept(requestId); // forward

  @override
  Future<List<UserMin>> allUsers() => s.getAllUsers(); // forward

  @override
  Future<void> block(int userId) => s.block(userId); // forward

  @override
  Future<void> cancelRequest(int friendId) => s.cancelFriend(friendId); // optional route

  @override
  Future<List<UserMin>> friends() => s.getFriends(); // forward

  @override
  Future<List<FriendRequestItem>> received() => s.getPending(); // forward

  @override
  Future<void> reject(int requestId) => s.reject(requestId); // forward

  @override
  Future<void> sendRequest(int friendId) => s.sendFriend(friendId); // forward

  @override
  Future<List<FriendRequestItem>> sent() => s.getSent(); // forward

  @override
  Future<List<UserMin>> suggestedUsers(int meId) => s.getSuggestedUsers(meId); // forward

  @override
  Future<void> unfriend(int userId) => s.unfriend(userId); // forward

  @override
  Future<void> unblock(int userId) => s.unblock(userId); // forward

  @override
  Future<void> cancelSent(int requestId) => s.cancelSentRequest(requestId); // used by Sent tab
}
