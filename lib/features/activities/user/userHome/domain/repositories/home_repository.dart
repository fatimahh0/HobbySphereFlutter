import 'package:hobby_sphere/features/activities/common/domain/entities/item_details.dart';

abstract class HomeRepository {
  Future<List<ItemDetailsEntity>> getInterestBased({
    required String token,
    required int userId,
  });

  Future<List<ItemDetailsEntity>> getUpcomingGuest({int? typeId});
}
