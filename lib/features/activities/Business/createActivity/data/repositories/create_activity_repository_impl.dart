import 'package:hobby_sphere/features/activities/Business/createActivity/data/services/business_create_activity_service.dart';
import 'package:hobby_sphere/features/activities/Business/createActivity/domain/entities/new_activity_input.dart';
import 'package:hobby_sphere/features/activities/Business/createActivity/domain/repositories/create_activity_repository.dart';

class CreateActivityRepositoryImpl implements CreateActivityRepository {
  final BusinessCreateActivityService service;
  CreateActivityRepositoryImpl(this.service);

  @override
  Future<Map<String, dynamic>> createActivity({
    required NewActivityInput input,
    required int businessId,
    required String token,
  }) {
    return service.createActivity(
      activity: input.toMap(),
      businessId: businessId,
      token: token,
    );
  }

  @override
  Future<List<dynamic>> getActivityTypes({required String token}) {
    return service.getActivityTypes(token: token);
  }
}
