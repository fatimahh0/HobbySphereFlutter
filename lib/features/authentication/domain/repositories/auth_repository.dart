import '../entities/auth_result.dart';

abstract class AuthRepository {
  Future<AuthResult> loginUserWithEmail({required String email, required String password});
  Future<AuthResult> loginUserWithPhone({required String phoneNumber, required String password});
  Future<AuthResult> loginBusinessWithEmail({required String email, required String password});
  Future<AuthResult> loginBusinessWithPhone({required String phoneNumber, required String password});
  Future<AuthResult> loginWithGoogle({required String idToken});
}
