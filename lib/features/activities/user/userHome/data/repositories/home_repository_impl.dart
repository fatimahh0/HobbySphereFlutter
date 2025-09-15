import 'package:hobby_sphere/features/activities/common/data/models/item_details_model.dart';
import 'package:hobby_sphere/features/activities/common/domain/entities/item_details.dart';

import '../../domain/repositories/home_repository.dart';
import '../services/home_service.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeService service;
  HomeRepositoryImpl(this.service);

  @override
  Future<List<ItemDetailsEntity>> getInterestBased({
    required String token,
    required int userId,
  }) async {
    final raw = await service.getInterestBased(token, userId);
    return raw.map((m) => ItemDetailsModel.fromJson(m).toEntity()).toList();
  }

  @override
  Future<List<ItemDetailsEntity>> getUpcomingGuest({int? typeId}) async {
    final raw = await service.getUpcomingGuest(typeId: typeId);
    return raw.map((m) => ItemDetailsModel.fromJson(m).toEntity()).toList();
  }
}
