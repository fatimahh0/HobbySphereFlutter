class ItemType {
  final int id;
  final String name;
  final String? icon;
  final String? iconLib;

  /// NEW: optional count from backend (activities/items available for this type)
  final int? itemsCount;

  const ItemType({
    required this.id,
    required this.name,
    this.icon,
    this.iconLib,
    this.itemsCount,
  });

  ItemType copyWith({
    int? id,
    String? name,
    String? icon,
    String? iconLib,
    int? itemsCount,
  }) {
    return ItemType(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      iconLib: iconLib ?? this.iconLib,
      itemsCount: itemsCount ?? this.itemsCount,
    );
  }
}
