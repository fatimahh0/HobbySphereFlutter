import '../entities/review.dart';
import '../repositories/review_repository.dart';

class GetBusinessReviews {
  final ReviewRepository repository;
  GetBusinessReviews(this.repository);

  Future<List<Review>> call(String token, int businessId) {
    return repository.getBusinessReviews(token, businessId);
  }
}
