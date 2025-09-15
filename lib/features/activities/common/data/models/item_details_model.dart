// Model + mapper from backend payload to domain entity
import '../../domain/entities/item_details.dart'; // entity

class ItemDetailsModel {
  final int id; // id
  final String itemName; // itemName
  final String? imageUrl; // imageUrl
  final String? location; // location
  final DateTime? start; // startDatetime
  final num? price; // price

  ItemDetailsModel({
    required this.id, // ctor id
    required this.itemName, // ctor name
    this.imageUrl, // optional image
    this.location, // optional location
    this.start, // optional dt
    this.price, // optional price
  });

  factory ItemDetailsModel.fromJson(Map<String, dynamic> j) {
    DateTime? _dt(dynamic v) =>
        v == null ? null : DateTime.tryParse('$v'); // parse date
    num? _num(dynamic v) =>
        v == null ? null : (v is num ? v : num.tryParse('$v')); // parse num

    return ItemDetailsModel(
      id: (j['id'] ?? 0) is int
          ? j['id'] as int
          : int.parse('${j['id']}'), // safe id
      itemName: (j['itemName'] ?? '').toString(), // name
      imageUrl: j['imageUrl']?.toString(), // image
      location: j['location']?.toString(), // location
      start: _dt(j['startDatetime']), // start
      price: _num(j['price']), // price
    );
  }

  ItemDetailsEntity toEntity() => ItemDetailsEntity(
    // to domain
    id: id,
    title: itemName,
    start: start,
    price: price,
    imageUrl: imageUrl,
    location: location,
  );
}
