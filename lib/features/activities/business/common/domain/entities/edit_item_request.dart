import 'dart:io';

class EditItemRequest {
  final int id; // item id to update
  final String name;
  final int itemTypeId;
  final String description;
  final String location;
  final double latitude;
  final double longitude;
  final int maxParticipants;
  final double price;
  final DateTime startDatetime;
  final DateTime endDatetime;
  final String status; // Active | Upcoming | Terminated
  final int businessId;
  final File? image; // optional new image
  final bool imageRemoved; // tell backend to remove current image

  EditItemRequest({
    required this.id,
    required this.name,
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
    this.imageRemoved = false,
  });
}
