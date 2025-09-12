// Flutter 3.35.x
// Auto-refresh analytics when activities or bookings change.

import 'dart:async'; // StreamSubscription
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessAnalytics/domain/usecases/get_business_analytics.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessAnalytics/presentation/bloc/business_analytics_event.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessAnalytics/presentation/bloc/business_analytics_state.dart';

// ⬇️ realtime imports
import 'package:hobby_sphere/core/realtime/realtime_bus.dart';
import 'package:hobby_sphere/core/realtime/event_models.dart';

class BusinessAnalyticsBloc
    extends Bloc<BusinessAnalyticsEvent, BusinessAnalyticsState> {
  final GetBusinessAnalytics getBusinessAnalytics; // use case

  // ⬇️ remember last params
  String? _token;
  int? _businessId;

  // ⬇️ subscription
  StreamSubscription<RealtimeEvent>? _rtSub;

  BusinessAnalyticsBloc({required this.getBusinessAnalytics})
    : super(BusinessAnalyticsInitial()) {
    on<LoadBusinessAnalytics>(_onLoadBusinessAnalytics); // first load
    on<RefreshBusinessAnalytics>(_onRefreshBusinessAnalytics); // manual refresh
    on<DownloadAnalyticsReport>(_onDownloadAnalyticsReport); // download pdf

    // ⬇️ realtime: refresh when same business gets activity/booking changes
    _rtSub = RealtimeBus.I.stream.listen((e) {
      if (_token == null || _businessId == null) return;
      final sameBiz = e.businessId == _businessId;
      final isInteresting =
          e.domain == Domain.activity || e.domain == Domain.booking;
      if (sameBiz && isInteresting) {
        add(RefreshBusinessAnalytics(token: _token!, businessId: _businessId!));
      }
    });
  }

  Future<void> _onLoadBusinessAnalytics(
    LoadBusinessAnalytics event,
    Emitter<BusinessAnalyticsState> emit,
  ) async {
    try {
      emit(BusinessAnalyticsLoading());
      _token = event.token; // remember token
      _businessId = event.businessId; // remember biz id
      final analytics = await getBusinessAnalytics(
        event.token,
        event.businessId,
      );
      emit(BusinessAnalyticsLoaded(analytics));
    } catch (e) {
      emit(BusinessAnalyticsError(e.toString()));
    }
  }

  Future<void> _onRefreshBusinessAnalytics(
    RefreshBusinessAnalytics event,
    Emitter<BusinessAnalyticsState> emit,
  ) async {
    try {
      final analytics = await getBusinessAnalytics(
        event.token,
        event.businessId,
      );
      emit(BusinessAnalyticsLoaded(analytics));
    } catch (e) {
      emit(BusinessAnalyticsError(e.toString()));
    }
  }

  Future<void> _onDownloadAnalyticsReport(
    DownloadAnalyticsReport event,
    Emitter<BusinessAnalyticsState> emit,
  ) async {
    final currentState = state;
    if (currentState is BusinessAnalyticsLoaded) {
      try {
        emit(BusinessAnalyticsDownloading(currentState.analytics));
        await Future.delayed(const Duration(seconds: 2)); // stub
        emit(
          BusinessAnalyticsDownloadSuccess(
            currentState.analytics,
            'Report downloaded successfully',
          ),
        );
        await Future.delayed(const Duration(seconds: 1));
        emit(BusinessAnalyticsLoaded(currentState.analytics));
      } catch (e) {
        emit(
          BusinessAnalyticsDownloadError(currentState.analytics, e.toString()),
        );
        await Future.delayed(const Duration(seconds: 2));
        emit(BusinessAnalyticsLoaded(currentState.analytics));
      }
    }
  }

  @override
  Future<void> close() async {
    await _rtSub?.cancel(); // cleanup
    return super.close();
  }
}
