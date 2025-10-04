// Flutter 3.35.x — simple and clean

import '../../domain/entities/item_type.dart'; // entity
import '../../domain/repositories/item_type_repository.dart'; // contract
import '../services/item_types_service.dart'; // http

class ItemTypeRepositoryImpl implements ItemTypeRepository {
  final ItemTypesService service; // http service
  ItemTypeRepositoryImpl(this.service); // inject

  @override
  Future<List<ItemType>> getItemTypes(String token) async {
    final raw = await service.getTypes(token); // call API
    final list = raw.map(ItemType.fromJson).toList(); // map to entity
    list.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    ); // sort
    return list; // return
  }
}
