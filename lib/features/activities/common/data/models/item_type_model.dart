import '../../domain/entities/item_type.dart';

class ItemTypeModel {
  final int id;
  final String name; // what we show in the dropdown
  final String? icon; // e.g., "PALETTE"
  final String? iconLib; // e.g., "Ionicons"

  ItemTypeModel({
    required this.id,
    required this.name,
    this.icon,
    this.iconLib,
  });

  // robust factory that accepts multiple key shapes
  factory ItemTypeModel.fromJson(Map<String, dynamic> j) {
    // try the common server keys in order
    final label = (j['displayName'] ?? j['activity_type'] ?? j['name'] ?? '')
        .toString()
        .trim();

    return ItemTypeModel(
      id: (j['id'] ?? 0) is int ? j['id'] as int : int.parse('${j['id']}'),
      name: label,
      icon: j['icon']?.toString(),
      iconLib: j['iconLib']?.toString(),
    );
  }

  ItemType toEntity() =>
      ItemType(id: id, name: name, icon: icon, iconLib: iconLib);
}
