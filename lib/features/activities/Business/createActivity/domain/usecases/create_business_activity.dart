import '../entities/new_activity_input.dart';
import '../repositories/create_activity_repository.dart';

class CreateBusinessActivity {
  final CreateActivityRepository repo;
  CreateBusinessActivity(this.repo);

  Future<Map<String, dynamic>> call({
    required NewActivityInput input,
    required int businessId,
    required String token,
  }) {
    return repo.createActivity(
      input: input,
      businessId: businessId,
      token: token,
    );
  }
}
