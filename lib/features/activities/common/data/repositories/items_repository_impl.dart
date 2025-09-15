// Repo implementation – items by type
import '../../domain/entities/item_details.dart'; // entity
import '../../domain/repositories/items_repository.dart'; // repo
import '../models/item_details_model.dart'; // model
import '../services/items_service.dart'; // service

class ItemsRepositoryImpl implements ItemsRepository {
  final ItemsService service; // dependency
  ItemsRepositoryImpl(this.service); // inject

  @override
  Future<List<ItemDetailsEntity>> getByType(int typeId) async {
    final raw = await service.getByType(typeId); // service call
    return raw
        .map((m) => ItemDetailsModel.fromJson(m).toEntity())
        .toList(); // map to entities
  }
}
