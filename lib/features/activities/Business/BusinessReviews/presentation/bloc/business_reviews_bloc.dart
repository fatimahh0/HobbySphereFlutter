import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_business_reviews.dart';
import 'business_reviews_event.dart';
import 'business_reviews_state.dart';

class BusinessReviewsBloc
    extends Bloc<BusinessReviewsEvent, BusinessReviewsState> {
  final GetBusinessReviews getReviews;

  BusinessReviewsBloc(this.getReviews) : super(BusinessReviewsInitial()) {
    on<LoadBusinessReviews>(_onLoad);
  }

  Future<void> _onLoad(
    LoadBusinessReviews event,
    Emitter<BusinessReviewsState> emit,
  ) async {
    try {
      emit(BusinessReviewsLoading());
      final reviews = await getReviews(event.token, event.businessId);
      emit(BusinessReviewsLoaded(reviews));
    } catch (e) {
      emit(BusinessReviewsError(e.toString()));
    }
  }
}
