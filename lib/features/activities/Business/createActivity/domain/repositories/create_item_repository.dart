import '../entities/create_item_request.dart';

abstract class CreateItemRepository {
  /// Returns success message from server.
  Future<String> createItem(String token, CreateItemRequest req);
}
