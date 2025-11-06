import '../../domain/entities/review.dart';

class ReviewModel extends Review {
  const ReviewModel({
    required int id,
    required String customerName,
    String? customerImage,
    required int rating,
    String? feedback,
    required String date,
    required String activityName,
  }) : super(
         id: id,
         customerName: customerName,
         customerImage: customerImage,
         rating: rating,
         feedback: feedback,
         date: date,
         activityName: activityName,
       );

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] ?? {};
    final item = json['item'] ?? {};

    return ReviewModel(
      id: json['id'] ?? 0,
      customerName:
          "${customer['firstName'] ?? ''} ${customer['lastName'] ?? ''}".trim(),
      customerImage: customer['profilePictureUrl'],
      rating: json['rating'] ?? 0,
      feedback: json['feedback'],
      date: json['date'] ?? '',
      activityName: item['itemName'] ?? '—',
    );
  }
}
