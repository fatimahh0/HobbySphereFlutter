import '../repositories/create_activity_repository.dart';

class GetActivityTypes {
  final CreateActivityRepository repo;
  GetActivityTypes(this.repo);

  Future<List<dynamic>> call({required String token}) {
    return repo.getActivityTypes(token: token);
  }
}
