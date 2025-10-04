// Flutter 3.35.x — simple and clean
import 'package:meta/meta.dart'; // @immutable

@immutable
class ItemType {
  final int id; // id
  final String name; // label for UI
  final String? icon; // backend icon key (e.g., "color-palette")
  final String? iconLib; // "Ionicons"
  final int? itemsCount; // optional

  const ItemType({
    required this.id, // required
    required this.name, // required
    this.icon, // optional
    this.iconLib, // optional
    this.itemsCount, // optional
  });

  // ✅ Prefer item_type → displayName → name → '—'
  factory ItemType.fromJson(Map<String, dynamic> json) {
    // read id safely
    final rawId = json['id'];
    // read candidate labels
    final label =
        (json['item_type'] ?? json['displayName'] ?? json['name'] ?? '')
            .toString()
            .trim();
    return ItemType(
      id: rawId is int ? rawId : int.tryParse('$rawId') ?? 0, // safe int
      name: label.isEmpty ? '—' : label, // safe label
      icon: json['icon']?.toString(), // keep raw icon key
      iconLib: json['iconLib']?.toString(), // keep lib
      itemsCount: (json['itemsCount'] is int)
          ? json['itemsCount'] as int
          : int.tryParse('${json['itemsCount'] ?? ''}'), // optional
    );
  }
}
