// interests_repository_impl.dart
// Uses the updated service + model.

import 'package:hobby_sphere/features/authentication/login&register/data/services/registration_service.dart';
import 'package:hobby_sphere/features/authentication/login&register/domain/entities/activity_type.dart';
import 'package:hobby_sphere/features/authentication/login&register/domain/repositories/interests_repository.dart';
import 'package:hobby_sphere/features/authentication/login&register/data/models/activity_type_model.dart';

class InterestsRepositoryImpl implements InterestsRepository {
  final RegistrationService service; // injected service
  InterestsRepositoryImpl(this.service);

  @override
  Future<List<ActivityType>> getAll() async {
    final raw = await service.fetchActivityTypes(); // GET categories
    return raw
        .map((m) => ActivityTypeModel.fromJson(m).toDomain()) // map each
        .toList(); // as list
  }
}
