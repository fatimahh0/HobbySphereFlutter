// domain/usecases/delete_banner.dart
import '../repositories/edit_business_repository.dart';

class DeleteBanner {
  final EditBusinessRepository repo;
  DeleteBanner(this.repo);

  Future<void> call(String token, int id) {
    return repo.deleteBanner(token, id);
  }
}
