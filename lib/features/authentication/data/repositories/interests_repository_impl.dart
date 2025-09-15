import 'package:hobby_sphere/features/authentication/data/models/activity_type_model.dart';
import 'package:hobby_sphere/features/authentication/data/services/registration_service.dart';
import 'package:hobby_sphere/features/authentication/domain/entities/activity_type.dart';
import 'package:hobby_sphere/features/authentication/domain/repositories/interests_repository.dart';

// concrete repo using RegistrationService
class InterestsRepositoryImpl implements InterestsRepository {
  final RegistrationService service; // hold service
  InterestsRepositoryImpl(this.service); // inject

  @override
  Future<List<ActivityType>> getAll() async {
    final list = await service.fetchActivityTypes(); // call service
    return list // map every item
        .map((m) => ActivityTypeModel.fromJson(m).toDomain())
        .toList();
  }
}
