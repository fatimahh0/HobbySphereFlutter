// Contract – fetch items filtered by type
import '../entities/item_details.dart'; // entity

abstract class ItemsRepository {
  Future<List<ItemDetailsEntity>> getByType(
    int typeId,
  ); // GET /items/by-type/{id}
}
