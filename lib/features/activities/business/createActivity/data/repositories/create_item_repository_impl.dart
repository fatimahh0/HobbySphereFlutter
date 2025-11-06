// ===== lib/features/activities/business/createActivity/data/repositories/create_item_repository_impl.dart =====
// Flutter 3.35.x
import 'package:dio/dio.dart'; // Dio for HTTP errors and response types
import '../../domain/entities/create_item_request.dart'; // Request entity (data to send)
import '../../domain/repositories/create_item_repository.dart'; // Repository interface
import '../services/create_item_service.dart'; // Service that performs the network call

class CreateItemRepositoryImpl implements CreateItemRepository {
  final CreateItemService service; // Service dependency
  CreateItemRepositoryImpl(this.service); // Inject service

  @override
  Future<String> createItem(String token, CreateItemRequest req) async {
    // Build payload map for multipart (File stays as File, strings as fields)
    final payload = {
      'name': req.name, //  must be 'name'
      'itemTypeId': req.itemTypeId, //  required
      'description': req.description, // Description
      'location': req.location, // Address text
      'latitude': req.latitude, // Lat
      'longitude': req.longitude, // Lng
      'maxParticipants': req.maxParticipants, // Capacity
      'price': req.price, // Price
      'startDatetime':
          req.startDatetime, // Can be DateTime or String (service normalizes)
      'endDatetime':
          req.endDatetime, // Can be DateTime or String (service normalizes)
      'status': req.status, // Status string
      'businessId': req.businessId, // Business owner id
      if (req.image != null) 'image': req.image, // Optional file (picked image)
      if (req.imageUrl != null && req.imageUrl!.isNotEmpty)
        'imageUrl': req.imageUrl, // Optional retained URL (when no file)
    };

    // Call multipart creator endpoint
    final res = await service.createMultipart(
      token,
      payload,
    ); // POST /items/create

    // Return server message on 200/201
    if (res.statusCode == 201 || res.statusCode == 200) {
      // Success codes
      final data = res.data; // Parse body
      if (data is Map && data['message'] is String)
        return data['message']; // Prefer message
      return 'Item created'; // Fallback text
    }

    // Throw a detailed DioException on error status
    throw DioException(
      // Bubble up error
      requestOptions: res.requestOptions, // Request info
      response: res, // Response info
      error: 'Create failed (${res.statusCode})', // Simple message
    );
  }
}
