import 'package:hobby_sphere/features/activities/common/domain/entities/item_details.dart';
import '../repositories/home_repository.dart';

class GetInterestBasedItems {
  final HomeRepository repository;
  GetInterestBasedItems(this.repository);

  Future<List<ItemDetailsEntity>> call({
    required String token,
    required int userId,
  }) {
    return repository.getInterestBased(token: token, userId: userId);
  }
}
