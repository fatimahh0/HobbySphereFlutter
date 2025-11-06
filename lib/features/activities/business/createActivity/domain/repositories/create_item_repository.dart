// ===== lib/features/activities/Business/createActivity/domain/repositories/create_item_repository.dart =====
// Flutter 3.35.x
import '../entities/create_item_request.dart'; // Request entity

abstract class CreateItemRepository {
  Future<String> createItem(
    String token,
    CreateItemRequest req,
  ); // Create and return message
}
