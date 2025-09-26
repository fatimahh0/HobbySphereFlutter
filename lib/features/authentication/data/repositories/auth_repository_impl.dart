// Converts raw Maps from service into AuthResult entity.

import 'package:hobby_sphere/features/authentication/domain/entities/auth_result.dart';
import 'package:hobby_sphere/features/authentication/domain/repositories/auth_repository.dart';

import '../services/auth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService service; // low-level dependency
  AuthRepositoryImpl(this.service); // inject service

  AuthResult _mapLogin(Map<String, dynamic> res, String role) {
    final wasInactive = (res['wasInactive'] == true);
    final isNewUser = (res['isNewUser'] == true); // NEW
    final token = '${res['token'] ?? res['jwt'] ?? ''}'.trim();

    // unwrap payloads
    final user = (res['user'] is Map) ? res['user'] as Map? : null;
    final biz = (res['business'] is Map) ? res['business'] as Map? : null;

    final subjectId = (role == 'business')
        ? (biz?['id'] is int
              ? biz!['id']
              : int.tryParse('${biz?['id'] ?? 0}') ?? 0)
        : (user?['id'] is int
              ? user!['id']
              : int.tryParse('${user?['id'] ?? 0}') ?? 0);

    final businessId = (role == 'business') ? subjectId : 0;

    return AuthResult(
      token: token,
      role: role,
      businessId: businessId,
      subjectId: subjectId,
      wasInactive: wasInactive,
      isNewUser: isNewUser, // NEW
      userId: (role == 'user') ? subjectId : 0, // NEW
      message: res['message']?.toString(),
      error:
          res['error']?.toString() ??
          (res['message']?.toString().startsWith('Incorrect') == true
              ? res['message']
              : null),
    );
  }

  @override
  Future<AuthResult> loginUserWithEmail({
    required String email,
    required String password,
  }) async {
    final res = await service.loginUserEmail(email: email, password: password);
    return _mapLogin(res, 'user');
  }

  @override
  Future<AuthResult> loginUserWithPhone({
    required String phoneNumber,
    required String password,
  }) async {
    final res = await service.loginUserPhone(
      phoneNumber: phoneNumber,
      password: password,
    );
    return _mapLogin(res, 'user');
  }

  @override
  Future<AuthResult> loginBusinessWithEmail({
    required String email,
    required String password,
  }) async {
    final res = await service.loginBusinessEmail(
      email: email,
      password: password,
    );
    return _mapLogin(res, 'business');
  }

  @override
  Future<AuthResult> loginBusinessWithPhone({
    required String phoneNumber,
    required String password,
  }) async {
    final res = await service.loginBusinessPhone(
      phoneNumber: phoneNumber,
      password: password,
    );
    return _mapLogin(res, 'business');
  }

  @override
  Future<AuthResult> loginWithGoogle({required String idToken}) async {
    final res = await service.loginGoogle(idToken); // google
    return _mapLogin(res, 'user'); // role=user
  }

  @override
  Future<AuthResult> reactivate({required int id, required String role}) async {
    final res = (role == 'business')
        ? await service.reactivateBusiness(id)
        : await service.reactivateUser(id);
    return _mapLogin(res, role);
  }
}
