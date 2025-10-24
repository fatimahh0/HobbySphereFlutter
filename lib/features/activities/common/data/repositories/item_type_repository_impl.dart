// lib/data/repositories/item_type_repository_impl.dart
// Flutter 3.35.x — project-scoped, token optional

import '../../domain/entities/item_type.dart';
import '../../domain/repositories/item_type_repository.dart';
import '../services/item_types_service.dart';

class ItemTypeRepositoryImpl implements ItemTypeRepository {
  final ItemTypesService service;
  ItemTypeRepositoryImpl(this.service);

  @override
  Future<List<ItemType>> getItemTypes([String? token]) async {
    // uses project-scoped endpoint with graceful fallback (guest/legacy)
    final raw = await service.getAllActivityTypes(); // no token required

    // map -> entity
    final list = raw.map<ItemType>((m) => ItemType.fromJson(m)).toList();

    // stable, null-safe sort
    list.sort(
      (a, b) =>
          (a.name ?? '').toLowerCase().compareTo((b.name ?? '').toLowerCase()),
    );
    return list;
  }
}
