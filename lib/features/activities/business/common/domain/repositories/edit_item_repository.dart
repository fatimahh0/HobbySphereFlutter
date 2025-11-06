import '../entities/edit_item_request.dart';

abstract class EditItemRepository {
  Future<String> updateItem(String token, EditItemRequest req);
}
