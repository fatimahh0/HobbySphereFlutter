import '../entities/edit_item_request.dart';
import '../repositories/edit_item_repository.dart';

class UpdateItem {
  final EditItemRepository repo;
  UpdateItem(this.repo);

  Future<String> call({required String token, required EditItemRequest req}) {
    return repo.updateItem(token, req);
  }
}
