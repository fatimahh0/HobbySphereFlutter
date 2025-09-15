// Model + mapper for ItemType (accepts many backend shapes)
import '../../domain/entities/item_type.dart'; // entity

class ItemTypeModel {
  final int id; // id
  final String name; // label to show
  final String? icon; // icon name
  final String? iconLib; // icon lib

  ItemTypeModel({
    required this.id, // ctor id
    required this.name, // ctor name
    this.icon, // optional icon
    this.iconLib, // optional lib
  });

  factory ItemTypeModel.fromJson(Map<String, dynamic> j) {
    final label = (j['displayName'] ?? j['activity_type'] ?? j['name'] ?? '')
        .toString()
        .trim(); // choose best name
    return ItemTypeModel(
      id: (j['id'] ?? 0) is int
          ? j['id'] as int
          : int.parse('${j['id']}'), // parse id safely
      name: label, // set name
      icon: j['icon']?.toString(), // set icon
      iconLib: j['iconLib']?.toString(), // set lib
    );
  }

  ItemType toEntity() => ItemType(
    // to domain entity
    id: id,
    name: name,
    icon: icon,
    iconLib: iconLib,
  );
}
