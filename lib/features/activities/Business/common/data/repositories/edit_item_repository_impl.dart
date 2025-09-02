import 'package:dio/dio.dart';
import '../../domain/entities/edit_item_request.dart';
import '../../domain/repositories/edit_item_repository.dart';
import '../services/edit_activity_service.dart';


class EditItemRepositoryImpl implements EditItemRepository {
  final UpdatedItemService service;
  EditItemRepositoryImpl(this.service);

  

  @override
  Future<String> updateItem(String token, EditItemRequest req) async {
    final payload = {
      'itemName': req.itemName,
      'itemTypeId': req.itemTypeId,
      'description': req.description,
      'location': req.location,
      'latitude': req.latitude,
      'longitude': req.longitude,
      'maxParticipants': req.maxParticipants,
      'price': req.price,
      'startDatetime': req.startDatetime,
      'endDatetime': req.endDatetime,
      'status': req.status,
      'businessId': req.businessId,
      'image': req.image,
      'imageRemoved': req.imageRemoved,
    };

    final res = await service.updateMultipart(token, req.id, payload);

    if (res.statusCode == 200) {
      final data = res.data;
      if (data is Map && data['message'] is String) return data['message'];
      return 'Item updated';
    }
    throw DioException(
      requestOptions: res.requestOptions,
      response: res,
      error: 'Update failed (${res.statusCode})',
    );
  }
}
