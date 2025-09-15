import 'package:hobby_sphere/features/activities/common/domain/entities/item_details.dart';
import '../repositories/home_repository.dart';

class GetUpcomingGuestItems {
  final HomeRepository repository;
  GetUpcomingGuestItems(this.repository);

  Future<List<ItemDetailsEntity>> call({int? typeId}) {
    return repository.getUpcomingGuest(typeId: typeId);
  }
}
