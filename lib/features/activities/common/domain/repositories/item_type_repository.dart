import '../entities/item_type.dart';

abstract class ItemTypeRepository {
  Future<List<ItemType>> getItemTypes(String token);
}
