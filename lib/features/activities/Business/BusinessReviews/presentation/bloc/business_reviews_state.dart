import 'package:equatable/equatable.dart';
import '../../domain/entities/review.dart';

abstract class BusinessReviewsState extends Equatable {
  const BusinessReviewsState();
  @override
  List<Object?> get props => [];
}

class BusinessReviewsInitial extends BusinessReviewsState {}

class BusinessReviewsLoading extends BusinessReviewsState {}

class BusinessReviewsLoaded extends BusinessReviewsState {
  final List<Review> reviews;
  const BusinessReviewsLoaded(this.reviews);
  @override
  List<Object?> get props => [reviews];
}

class BusinessReviewsError extends BusinessReviewsState {
  final String message;
  const BusinessReviewsError(this.message);
  @override
  List<Object?> get props => [message];
}
