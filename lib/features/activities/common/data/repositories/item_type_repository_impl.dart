import '../../domain/entities/item_type.dart';
import '../../domain/repositories/item_type_repository.dart';
import '../models/item_type_model.dart';
import '../services/item_types_service.dart';

class ItemTypeRepositoryImpl implements ItemTypeRepository {
  final ItemTypesService service;
  ItemTypeRepositoryImpl(this.service);

  @override
  Future<List<ItemType>> getItemTypes(String token) async {
    final raw = await service.getTypes(token); // List<Map<String,dynamic>>
    return raw.map((m) => ItemTypeModel.fromJson(m).toEntity()).toList();
  }
}
