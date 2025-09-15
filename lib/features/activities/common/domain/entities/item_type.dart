// Flutter 3.35.x
// Entity (your old shape) – UI shows "name"
class ItemType {
  final int id; // id
  final String name; // display name text
  final String? icon; // icon id from backend (Ionicons name)
  final String? iconLib; // icon library name (e.g., "Ionicons")

  const ItemType({
    required this.id, // require id
    required this.name, // require name
    this.icon, // optional icon id
    this.iconLib, // optional library
  });
}
