import '../../entities/activity_type.dart'; // entity
import '../../repositories/interests_repository.dart'; // repo

// query-usecase to get interests
class GetActivityTypes {
  final InterestsRepository repo; // repo
  GetActivityTypes(this.repo); // inject

  Future<List<ActivityType>> call() => repo.getAll(); // forward
}
