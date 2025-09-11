import '../entities/manager_invite_result.dart';

abstract class ManagerInviteRepository {
  Future<ManagerInviteResult> sendInvite({
    required String token,
    required int businessId,
    required String email,
  });
}
