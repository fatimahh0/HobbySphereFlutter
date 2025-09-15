// Minimal activity item entity used in lists (cards)
class ItemDetailsEntity {
  final int id; // item id
  final String title; // itemName
  final DateTime? start; // startDatetime
  final num? price; // price number
  final String? imageUrl; // image path/url
  final String? location; // location text

  const ItemDetailsEntity({
    required this.id, // required
    required this.title, // required
    this.start, // optional
    this.price, // optional
    this.imageUrl, // optional
    this.location, // optional
  });
}
