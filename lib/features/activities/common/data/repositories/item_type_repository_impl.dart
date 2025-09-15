// Repo implementation – maps model -> entity
import '../../domain/entities/item_type.dart'; // entity
import '../../domain/repositories/item_type_repository.dart'; // repo
import '../models/item_type_model.dart'; // model
import '../services/item_types_service.dart'; // service

class ItemTypeRepositoryImpl implements ItemTypeRepository {
  final ItemTypesService service; // dependency
  ItemTypeRepositoryImpl(this.service); // inject

  @override
  Future<List<ItemType>> getItemTypes(String token) async {
    final raw = await service.getTypes(token); // service call
    return raw
        .map((m) => ItemTypeModel.fromJson(m).toEntity())
        .toList(); // map to entities
  }
}
