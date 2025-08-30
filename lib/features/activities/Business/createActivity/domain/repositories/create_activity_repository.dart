import '../entities/new_activity_input.dart';

abstract class CreateActivityRepository {
  Future<Map<String, dynamic>> createActivity({
    required NewActivityInput input,
    required int businessId,
    required String token,
  });

  Future<List<dynamic>> getActivityTypes({required String token});
}
