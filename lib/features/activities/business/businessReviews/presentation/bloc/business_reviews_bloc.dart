// Flutter 3.35.x
// BusinessReviewsBloc — load reviews, realtime refresh for same business.

import 'dart:async'; // StreamSubscription
import 'package:flutter_bloc/flutter_bloc.dart'; // Bloc base

import '../../domain/usecases/get_business_reviews.dart'; // use case
import 'business_reviews_event.dart'; // events (positional constructors)
import 'business_reviews_state.dart'; // state

// realtime
import 'package:hobby_sphere/core/realtime/realtime_bus.dart'; // bus
import 'package:hobby_sphere/core/realtime/event_models.dart'; // Domain

class BusinessReviewsBloc
    extends Bloc<BusinessReviewsEvent, BusinessReviewsState> {
  final GetBusinessReviews getReviews; // use case

  String? _token; // remember token
  int? _businessId; // remember business id
  StreamSubscription<RealtimeEvent>? _rtSub; // subscription holder

  BusinessReviewsBloc(this.getReviews) : super(BusinessReviewsInitial()) {
    on<LoadBusinessReviews>(_onLoad); // load handler

    // realtime: review domain for same business → reload
    _rtSub = RealtimeBus.I.stream.listen((e) {
      if (e.domain != Domain.review) return; // only review events
      if (_token == null || _businessId == null) return; // need scope
      if (e.businessId == _businessId) {
        // same business
        add(LoadBusinessReviews(_token!, _businessId!)); // ✅ positional (fix)
      }
    });
  }

  Future<void> _onLoad(
    LoadBusinessReviews event,
    Emitter<BusinessReviewsState> emit,
  ) async {
    try {
      emit(BusinessReviewsLoading()); // show loader
      _token = event.token; // remember token
      _businessId = event.businessId; // remember id
      final reviews = await getReviews(event.token, event.businessId); // fetch
      emit(BusinessReviewsLoaded(reviews)); // show data
    } catch (e) {
      emit(BusinessReviewsError(e.toString())); // error
    }
  }

  @override
  Future<void> close() async {
    await _rtSub?.cancel(); // stop realtime
    return super.close(); // finish close
  }
}
