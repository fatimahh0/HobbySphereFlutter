

// read-only repo for activity types
import 'package:hobby_sphere/features/authentication/login&register/domain/entities/activity_type.dart';

abstract class InterestsRepository {
  Future<List<ActivityType>> getAll(); // fetch all
}
