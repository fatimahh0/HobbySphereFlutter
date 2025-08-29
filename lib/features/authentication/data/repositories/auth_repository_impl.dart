import 'package:hobby_sphere/features/activities/common/data/services/auth_service.dart';
import 'package:hobby_sphere/features/authentication/domain/entities/auth_result.dart';
import 'package:hobby_sphere/features/authentication/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService service;
  AuthRepositoryImpl(this.service);

  AuthResult _mapResult(Map<String, dynamic> res, String role) {
    final token = '${res['token'] ?? res['jwt'] ?? ''}'.trim();
    final status = res['_status'] is int ? res['_status'] as int : 200;

    int businessId = 0;
    if (role == 'business') {
      final b = res['business'] ?? res;
      final rawId = (b is Map && b['id'] != null)
          ? b['id']
          : (res['businessId'] ?? res['id'] ?? res['userId']);
      businessId = rawId is int ? rawId : int.tryParse('$rawId') ?? 0;
    }

    return AuthResult(
      token: token,
      role: role,
      businessId: businessId,
      statusCode: status,
      message: res['message']?.toString(),
      error: res['error']?.toString(),
    );
  }

  @override
  Future<AuthResult> loginUserWithEmail({
    required String email,
    required String password,
  }) async {
    final res = await service.loginWithEmailPassword(
      email: email,
      password: password,
    );
    return _mapResult(res, 'user');
  }

  @override
  Future<AuthResult> loginUserWithPhone({
    required String phoneNumber,
    required String password,
  }) async {
    final res = await service.loginWithPhonePassword(
      phoneNumber: phoneNumber,
      password: password,
    );
    return _mapResult(res, 'user');
  }

  @override
  Future<AuthResult> loginBusinessWithEmail({
    required String email,
    required String password,
  }) async {
    final res = await service.loginBusiness(email: email, password: password);
    return _mapResult(res, 'business');
  }

  @override
  Future<AuthResult> loginBusinessWithPhone({
    required String phoneNumber,
    required String password,
  }) async {
    final res = await service.loginBusinessWithPhone(
      phoneNumber: phoneNumber,
      password: password,
    );
    return _mapResult(res, 'business');
  }

  @override
  Future<AuthResult> loginWithGoogle({required String idToken}) async {
    final res = await service.loginWithGoogle(idToken);
    return _mapResult(res, 'user');
  }
}
