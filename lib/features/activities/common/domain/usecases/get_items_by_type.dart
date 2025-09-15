// Usecase to fetch activities by type id
import '../entities/item_details.dart'; // entity
import '../repositories/items_repository.dart'; // repo

class GetItemsByType {
  final ItemsRepository repo; // dependency
  GetItemsByType(this.repo); // inject
  Future<List<ItemDetailsEntity>> call(int typeId) {
    // run
    return repo.getByType(typeId); // forward to repo
  }
}
