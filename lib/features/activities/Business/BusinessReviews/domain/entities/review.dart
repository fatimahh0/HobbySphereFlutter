import 'package:equatable/equatable.dart';

class Review extends Equatable {
  final int id;
  final String customerName;
  final String? customerImage;
  final int rating;
  final String? feedback;
  final String date;
  final String activityName;

  const Review({
    required this.id,
    required this.customerName,
    this.customerImage,
    required this.rating,
    this.feedback,
    required this.date,
    required this.activityName,
  });

  @override
  List<Object?> get props => [
    id,
    customerName,
    rating,
    feedback,
    date,
    activityName,
  ];
}
