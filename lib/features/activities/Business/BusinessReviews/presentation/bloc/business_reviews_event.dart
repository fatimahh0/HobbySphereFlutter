import 'package:equatable/equatable.dart';

abstract class BusinessReviewsEvent extends Equatable {
  const BusinessReviewsEvent();
  @override
  List<Object?> get props => [];
}

class LoadBusinessReviews extends BusinessReviewsEvent {
  final String token;
  final int businessId;

  const LoadBusinessReviews(this.token, this.businessId);

  @override
  List<Object?> get props => [token, businessId];
}
