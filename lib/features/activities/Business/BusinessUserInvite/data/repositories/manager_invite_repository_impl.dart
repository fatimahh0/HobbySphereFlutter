import '../../domain/entities/manager_invite_result.dart';
import '../../domain/repositories/manager_invite_repository.dart';
import '../models/manager_invite_request.dart';
import '../services/manager_invite_service.dart';

class ManagerInviteRepositoryImpl implements ManagerInviteRepository {
  final ManagerInviteService service;
  ManagerInviteRepositoryImpl({required this.service});

  @override
  Future<ManagerInviteResult> sendInvite({
    required String token,
    required int businessId,
    required String email,
  }) async {
    final res = await service.sendInvite(
      token: token,
      businessId: businessId,
      body: ManagerInviteRequest(email: email),
    );

    if (!res.ok) {
      return ManagerInviteResult(success: false, message: res.error!);
    }
    final msg = (res.message?.isNotEmpty ?? false)
        ? res.message!
        : 'Invitation sent';
    return ManagerInviteResult(success: true, message: msg);
  }
}
