import 'package:hobby_sphere/features/activities/Business/common/domain/entities/business_activity.dart';
import 'package:hobby_sphere/features/activities/Business/common/domain/repositories/business_activity_repository.dart';
import '../services/business_activity_service.dart';

class BusinessActivityRepositoryImpl implements BusinessActivityRepository {
  final BusinessActivityService service;
  BusinessActivityRepositoryImpl(this.service);

  BusinessActivity _map(Map<String, dynamic> e) {
    final id = (e['id'] as num?)?.toInt() ?? 0;
    final name = (e['itemName'] ?? 'Unnamed').toString();
    final type = (e['itemType']?['activity_type'] ?? '').toString();
    final status = (e['status'] ?? '').toString();
    final imageUrl = e['imageUrl']?.toString();

    DateTime? startDate;
    final sd = e['startDatetime'];
    if (sd is String) {
      startDate = DateTime.tryParse(sd);
    } else if (sd is num) {
      startDate = DateTime.fromMillisecondsSinceEpoch(sd.toInt());
    }

    final maxParticipants = (e['maxParticipants'] as num?)?.toInt() ?? 0;
    final price = (e['price'] as num?)?.toDouble() ?? 0.0;

    return BusinessActivity(
      id: id,
      name: name,
      type: type,
      startDate: startDate,
      maxParticipants: maxParticipants,
      price: price,
      status: status,
      imageUrl: imageUrl,
    );
  }

  @override
  Future<List<BusinessActivity>> getActivitiesByBusiness({
    required int businessId,
    required String token,
  }) async {
    final list = await service.getActivitiesByBusiness(
      businessId: businessId,
      token: token,
    );
    return list
        .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
        .map(_map)
        .toList();
  }

  @override
  Future<BusinessActivity> getById({
    required String token,
    required int id,
  }) async {
    final raw = await service.getBusinessActivityById(token, id);
    return _map(Map<String, dynamic>.from(raw));
  }

  @override
  Future<void> delete({
    required String token,
    required int id,
  }) {
    return service.deleteBusinessActivity(token, id);
  }
}
