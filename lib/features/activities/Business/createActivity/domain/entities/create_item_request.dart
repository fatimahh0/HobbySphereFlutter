import 'dart:io';

class CreateItemRequest {
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
  final String status; // e.g. "ACTIVE"
  final int businessId;
  final File? image;
  final String? imageUrl;

  CreateItemRequest({
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
    this.image,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'itemName': itemName,
      'itemTypeId': itemTypeId,
      'description': description,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'maxParticipants': maxParticipants,
      'price': price,
      'startDatetime': startDatetime.toIso8601String(),
      'endDatetime': endDatetime.toIso8601String(),
      'status': status,
      'businessId': businessId,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }
}
