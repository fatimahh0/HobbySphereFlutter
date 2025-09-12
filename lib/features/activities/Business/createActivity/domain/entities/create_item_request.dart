// ===== lib/features/activities/Business/createActivity/domain/entities/create_item_request.dart =====
// Flutter 3.35.x
import 'dart:io'; // File type

class CreateItemRequest {
  final String itemName; // Name
  final int itemTypeId; // Type id
  final String description; // Description
  final String location; // Address
  final double latitude; // Lat
  final double longitude; // Lng
  final int maxParticipants; // Capacity
  final double price; // Price
  final DateTime startDatetime; // Start date-time
  final DateTime endDatetime; // End date-time
  final String status; // Status
  final int businessId; // Business id
  final File? image; // Optional picked file
  final String? imageUrl; // Optional retained URL

  CreateItemRequest({
    required this.itemName, // Set name
    required this.itemTypeId, // Set type
    required this.description, // Set description
    required this.location, // Set address
    required this.latitude, // Set lat
    required this.longitude, // Set lng
    required this.maxParticipants, // Set capacity
    required this.price, // Set price
    required this.startDatetime, // Set start
    required this.endDatetime, // Set end
    required this.status, // Set status
    required this.businessId, // Set business
    this.image, // Optional file
    this.imageUrl, // Optional URL
  });

  Map<String, dynamic> toJson() {
    return {
      'itemName': itemName, // Name
      'itemTypeId': itemTypeId, // Type id
      'description': description, // Desc
      'location': location, // Address
      'latitude': latitude, // Lat
      'longitude': longitude, // Lng
      'maxParticipants': maxParticipants, // Capacity
      'price': price, // Price
      'startDatetime': startDatetime
          .toIso8601String(), // ISO start (not used in multipart, but handy)
      'endDatetime': endDatetime.toIso8601String(), // ISO end
      'status': status, // Status
      'businessId': businessId, // Business id
      if (imageUrl != null) 'imageUrl': imageUrl, // Keep URL if present
    };
  }
}
