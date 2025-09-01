import '../entities/item_type.dart';
import '../repositories/item_type_repository.dart';

class GetItemTypes {
  final ItemTypeRepository repository;
  GetItemTypes(this.repository);

  Future<List<ItemType>> call(String token) {
    return repository.getItemTypes(token);
  }
}
