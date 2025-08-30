import '../repositories/business_activity_repository.dart';

class DeleteBusinessActivity {
  final BusinessActivityRepository repo;
  DeleteBusinessActivity(this.repo);

  Future<void> call({
    required String token,
    required int id,
  }) {
    return repo.delete(token: token, id: id);
  }
}
