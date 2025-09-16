import '../../domain/entities/item_type.dart';

class ItemTypeModel {
  final int id;
  final String name;
  final String? icon;
  final String? iconLib;

  /// NEW: normalized count field (if backend provides one)
  final int? itemsCount;

  ItemTypeModel({
    required this.id,
    required this.name,
    this.icon,
    this.iconLib,
    this.itemsCount,
  });

  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse('$v');
  }

  factory ItemTypeModel.fromJson(Map<String, dynamic> j) {
    // name can come as: displayName / activity_type / name
    final label = (j['displayName'] ?? j['activity_type'] ?? j['name'] ?? '')
        .toString()
        .trim();

    // count can come in many keys — we normalize them all
    final rawCount =
        j['activitiesCount'] ??
        j['itemsCount'] ??
        j['count'] ??
        j['total'] ??
        j['items_count'] ??
        j['activities_count'];

    return ItemTypeModel(
      id: (j['id'] ?? 0) is int ? j['id'] as int : int.parse('${j['id']}'),
      name: label,
      icon: j['icon']?.toString(),
      iconLib: j['iconLib']?.toString(),
      itemsCount: _asInt(rawCount),
    );
  }

  ItemType toEntity() => ItemType(
    id: id,
    name: name,
    icon: icon,
    iconLib: iconLib,
    itemsCount: itemsCount,
  );
}
