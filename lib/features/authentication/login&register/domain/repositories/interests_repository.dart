import '../entities/activity_type.dart'; // entity

// read-only repo for activity types
abstract class InterestsRepository {
  Future<List<ActivityType>> getAll(); // fetch all
}
