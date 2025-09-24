import '../entities/friend_request.dart';
import '../entities/user_min.dart';
import '../repositories/friends_repository.dart';

// Each UC is a tiny callable class (keeps UI thin).
class GetAllUsersUC { final FriendsRepository r; GetAllUsersUC(this.r); Future<List<UserMin>> call()=>r.allUsers(); }
class GetSuggestedUC { final FriendsRepository r; GetSuggestedUC(this.r); Future<List<UserMin>> call(int me)=>r.suggestedUsers(me); }
class SendFriendUC { final FriendsRepository r; SendFriendUC(this.r); Future<void> call(int id)=>r.sendRequest(id); }

class GetReceivedUC { final FriendsRepository r; GetReceivedUC(this.r); Future<List<FriendRequestItem>> call()=>r.received(); }
class GetSentUC { final FriendsRepository r; GetSentUC(this.r); Future<List<FriendRequestItem>> call()=>r.sent(); }
class GetFriendsUC { final FriendsRepository r; GetFriendsUC(this.r); Future<List<UserMin>> call()=>r.friends(); }
class AcceptUC { final FriendsRepository r; AcceptUC(this.r); Future<void> call(int req)=>r.accept(req); }
class RejectUC { final FriendsRepository r; RejectUC(this.r); Future<void> call(int req)=>r.reject(req); }
class UnfriendUC { final FriendsRepository r; UnfriendUC(this.r); Future<void> call(int uid)=>r.unfriend(uid); }
class BlockUC { final FriendsRepository r; BlockUC(this.r); Future<void> call(int uid)=>r.block(uid); }
class UnblockUC { final FriendsRepository r; UnblockUC(this.r); Future<void> call(int uid)=>r.unblock(uid); }
class CancelFriendUC {
  final FriendsRepository r; // repo
  CancelFriendUC(this.r); // inject
  Future<void> call(int requestId) => r.cancelSent(requestId); // forward
}
