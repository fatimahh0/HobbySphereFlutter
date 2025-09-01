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
  });
}
