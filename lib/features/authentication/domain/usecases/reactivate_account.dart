import '../entities/auth_result.dart';
import '../repositories/auth_repository.dart';

class ReactivateAccount {
  final AuthRepository repo;
  ReactivateAccount(this.repo);
  Future<AuthResult> call({required int id, required String role}) =>
      repo.reactivate(id: id, role: role);
}
