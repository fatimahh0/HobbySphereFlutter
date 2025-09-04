import '../entities/review.dart';

abstract class ReviewRepository {
  Future<List<Review>> getBusinessReviews(String token, int businessId);
}
