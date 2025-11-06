import '../repositories/edit_business_repository.dart';

class UpdateBusiness {
  final EditBusinessRepository repo;
  UpdateBusiness(this.repo);

  Future<void> call(
    String token,
    int id,
    Map<String, dynamic> body, {
    bool withImages = false,
  }) {
    return repo.updateBusiness(token, id, body, withImages: withImages);
  }
}
