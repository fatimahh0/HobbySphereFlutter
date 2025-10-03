// Contract – fetch types using token
import '../entities/item_type.dart'; // entity

abstract class ItemTypeRepository {
  Future<List<ItemType>> getItemTypes(String token); // GET /item-type
}
