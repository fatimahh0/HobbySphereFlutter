import 'package:dio/dio.dart';
import '../../domain/entities/create_item_request.dart';
import '../../domain/repositories/create_item_repository.dart';
import '../services/create_item_service.dart';

class CreateItemRepositoryImpl implements CreateItemRepository {
  final CreateItemService service;
  CreateItemRepositoryImpl(this.service);

  @override
  Future<String> createItem(String token, CreateItemRequest req) async {
    final payload = {
      'itemName': req.itemName,
      'itemTypeId': req.itemTypeId,
      'description': req.description,
      'location': req.location,
      'latitude': req.latitude,
      'longitude': req.longitude,
      'maxParticipants': req.maxParticipants,
      'price': req.price,
      'startDatetime': req.startDatetime.toIso8601String(),
      'endDatetime': req.endDatetime.toIso8601String(),
      'status': req.status,
      'businessId': req.businessId,
      'image': req.image,
    };

    final res = await service.createMultipart(token, payload);

    if (res.statusCode == 201 || res.statusCode == 200) {
      final data = res.data;
      if (data is Map && data['message'] is String) return data['message'];
      return 'Item created';
    }
    throw DioException(
      requestOptions: res.requestOptions,
      response: res,
      error: 'Create failed (${res.statusCode})',
    );
  }
}
