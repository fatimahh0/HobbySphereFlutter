import '../entities/create_item_request.dart';
import '../repositories/create_item_repository.dart';

class CreateItem {
  final CreateItemRepository repo;
  CreateItem(this.repo);

  Future<String> call({required String token, required CreateItemRequest req}) {
    return repo.createItem(token, req);
  }
}
