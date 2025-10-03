import 'package:hobby_sphere/features/authentication/login&register/domain/entities/activity_type.dart';

import '../../repositories/interests_repository.dart'; // repo

// query-usecase to get interests
class GetActivityTypes {
  final InterestsRepository repo; // repo
  GetActivityTypes(this.repo); // inject

  Future<List<ActivityType>> call() => repo.getAll(); // forward
}
