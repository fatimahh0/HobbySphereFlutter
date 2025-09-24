import '../entities/friend_request.dart';
import '../entities/user_min.dart';

// Repository contract for friends / friendship flows.
abstract class FriendsRepository {
  Future<List<UserMin>> allUsers(); // GET /api/users/all
  Future<List<UserMin>> suggestedUsers(
    int meId,
  ); // GET /api/users/{id}/suggestions
  Future<void> sendRequest(int friendId); // POST /api/friends/add/{id}
  Future<void> cancelRequest(int friendId); // DELETE /api/friends/cancel/{id}
  Future<List<FriendRequestItem>> received(); // GET /api/friends/pending
  Future<List<FriendRequestItem>> sent(); // GET /api/friends/sent
  Future<List<UserMin>> friends(); // GET /api/friends/my
  Future<void> accept(int requestId); // POST /api/friends/accept/{requestId}
  Future<void> reject(int requestId); // POST /api/friends/reject/{requestId}
  Future<void> unfriend(int userId); // DELETE /api/friends/unfriend/{userId}
  Future<void> block(int userId); // POST /api/friends/block/{userId}
  Future<void> unblock(int userId); // DELETE /api/friends/unblock/{userId}
   Future<void> cancelSent(
    int requestId,
  ); // DELETE /api/friends/cancel/{requestId}
}
