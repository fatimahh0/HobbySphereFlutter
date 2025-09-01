class ItemType {
  final int id;
  final String name; // what the UI displays
  final String? icon;
  final String? iconLib;

  const ItemType({
    required this.id,
    required this.name,
    this.icon,
    this.iconLib,
  });
}
