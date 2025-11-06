// features/.../createActivity/domain/entities/item_details.dart
class ItemDetails {
  final int id;
  final String itemName;
  final int itemTypeId;
  final String description;
  final String location;
  final double latitude;
  final double longitude;
  final int maxParticipants;
  final double price;
  final DateTime startDatetime;
  final DateTime endDatetime;
  final String status;
  final int businessId;
  final String? imageUrl;

  ItemDetails({
    required this.id,
    required this.itemName,
    required this.itemTypeId,
    required this.description,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.maxParticipants,
    required this.price,
    required this.startDatetime,
    required this.endDatetime,
    required this.status,
    required this.businessId,
    this.imageUrl,
  });

  factory ItemDetails.fromJson(Map<String, dynamic> json) => ItemDetails(
    id: json['id'],
    itemName: json['itemName'],
    itemTypeId: json['itemTypeId'],
    description: json['description'] ?? '',
    location: json['location'] ?? '',
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    maxParticipants: (json['maxParticipants'] as num).toInt(),
    price: (json['price'] as num).toDouble(),
    startDatetime: DateTime.parse(json['startDatetime']),
    endDatetime: DateTime.parse(json['endDatetime']),
    status: (json['status'] ?? '').toString(),
    businessId: (json['business']?['id'] ?? json['businessId']) as int,
    imageUrl: json['imageUrl'] as String?,
  );
}
