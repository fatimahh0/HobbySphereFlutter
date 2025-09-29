// 📦 Friends repository contract (used by UCs/Bloc).
import '../entities/friend_request.dart';
import '../entities/user_min.dart';

abstract class FriendsRepository {
  Future<List<UserMin>> allUsers(); // GET all users
  Future<List<UserMin>> suggestedUsers(int meId); // GET suggestions
  Future<void> sendRequest(int friendId); // POST add
  Future<void> cancelRequest(int friendId); // DELETE cancel by user (optional)
  Future<void> cancelSent(int requestId); // DELETE cancel by requestId (sent)
  Future<List<FriendRequestItem>> received(); // GET pending
  Future<List<FriendRequestItem>> sent(); // GET sent
  Future<List<UserMin>> friends(); // GET my
  Future<void> accept(int requestId); // POST accept
  Future<void> reject(int requestId); // POST reject
  Future<void> unfriend(int userId); // DELETE unfriend
  Future<void> block(int userId); // POST block
  Future<void> unblock(int userId); // DELETE unblock
}
