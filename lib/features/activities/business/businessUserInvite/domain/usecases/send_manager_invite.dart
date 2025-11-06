import '../entities/manager_invite_result.dart';
import '../repositories/manager_invite_repository.dart';

class SendManagerInvite {
  final ManagerInviteRepository repo;
  SendManagerInvite(this.repo);

  Future<ManagerInviteResult> call({
    required String token,
    required int businessId,
    required String email,
  }) {
    return repo.sendInvite(token: token, businessId: businessId, email: email);
  }
}
