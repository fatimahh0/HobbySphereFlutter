// Contract the app depends on (no Dio/HTTP here).
import '../entities/auth_result.dart';

abstract class AuthRepository {
  Future<AuthResult> loginUserWithEmail({
    required String email,
    required String password,
  }); // user email login
  Future<AuthResult> loginUserWithPhone({
    required String phoneNumber,
    required String password,
  }); // user phone login
  Future<AuthResult> loginBusinessWithEmail({
    required String email,
    required String password,
  }); // biz email login
  Future<AuthResult> loginBusinessWithPhone({
    required String phoneNumber,
    required String password,
  }); // biz phone login
  Future<AuthResult> loginWithGoogle({
    required String idToken,
  }); // optional google
  Future<AuthResult> reactivate({
    required int id,
    required String role,
  }); // reactivate call
}
