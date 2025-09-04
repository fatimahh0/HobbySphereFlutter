import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';
import '../models/review_model.dart';
import '../services/review_service.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewService service;
  ReviewRepositoryImpl(this.service);

  @override
  Future<List<Review>> getBusinessReviews(String token, int businessId) async {
    final list = await service.getBusinessReviews(token, businessId);
    return list.map((e) => ReviewModel.fromJson(e)).toList();
  }
}
