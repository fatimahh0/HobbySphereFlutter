// ===== Flutter 3.35.x =====
// Auto-refresh analytics when activities/bookings/reviews/analytics change.

import 'dart:async'; // StreamSubscription + Timer
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

  // remember last params
  String? _token; // last JWT
  int? _businessId; // last businessId

  // realtime subscription + debounce
  StreamSubscription<RealtimeEvent>? _rtSub; // ws sub
  Timer? _refreshDebounce; // debounce timer

  BusinessAnalyticsBloc({required this.getBusinessAnalytics})
    : super(BusinessAnalyticsInitial()) {
    on<LoadBusinessAnalytics>(_onLoadBusinessAnalytics); // first load
    on<RefreshBusinessAnalytics>(_onRefreshBusinessAnalytics); // manual/auto
    on<DownloadAnalyticsReport>(_onDownloadAnalyticsReport); // pdf

    // realtime: when same business changes, refresh analytics
    _rtSub = RealtimeBus.I.stream.listen((e) {
      // must have context
      if (_token == null || _businessId == null) return;

      // only my business
      final sameBiz =
          e.businessId == _businessId ||
          e.businessId == 0; // 👈 allow wildcard 0
      final isInteresting =
          e.domain == Domain.activity ||
          e.domain == Domain.booking ||
          e.domain == Domain.review ||
          e.domain == Domain.analytics ||
          (e.domain == Domain.profile && e.action == ActionType.updated);

      if (sameBiz && isInteresting) {
        _debouncedRefresh(); // refresh analytics (revenue updates now)
      }
    });
  }

  // debounce helper → collapse bursts into one refresh
  void _debouncedRefresh() {
    _refreshDebounce?.cancel(); // cancel pending
    _refreshDebounce = Timer(const Duration(milliseconds: 400), () {
      if (_token != null && _businessId != null) {
        add(
          RefreshBusinessAnalytics(
            // dispatch refresh
            token: _token!,
            businessId: _businessId!,
          ),
        );
      }
    });
  }

  // initial load (also stores params for realtime)
  Future<void> _onLoadBusinessAnalytics(
    LoadBusinessAnalytics event,
    Emitter<BusinessAnalyticsState> emit,
  ) async {
    try {
      emit(BusinessAnalyticsLoading()); // loading
      _token = event.token; // remember token
      _businessId = event.businessId; // remember id
      final analytics = await getBusinessAnalytics(
        // call use case
        event.token,
        event.businessId,
      );
      emit(BusinessAnalyticsLoaded(analytics)); // show data
    } catch (e) {
      emit(BusinessAnalyticsError(e.toString())); // error
    }
  }

  // refresh handler (used by pull-to-refresh AND realtime)
  Future<void> _onRefreshBusinessAnalytics(
    RefreshBusinessAnalytics event,
    Emitter<BusinessAnalyticsState> emit,
  ) async {
    try {
      final analytics = await getBusinessAnalytics(
        // call use case
        event.token,
        event.businessId,
      );
      emit(BusinessAnalyticsLoaded(analytics)); // show data
    } catch (e) {
      emit(BusinessAnalyticsError(e.toString())); // error
    }
  }

  // download pdf (kept as-is)
  Future<void> _onDownloadAnalyticsReport(
    DownloadAnalyticsReport event,
    Emitter<BusinessAnalyticsState> emit,
  ) async {
    final currentState = state;
    if (currentState is BusinessAnalyticsLoaded) {
      try {
        emit(BusinessAnalyticsDownloading(currentState.analytics)); // busy
        await Future.delayed(const Duration(seconds: 2)); // stub
        emit(
          BusinessAnalyticsDownloadSuccess(
            currentState.analytics,
            'Report downloaded successfully',
          ),
        );
        await Future.delayed(const Duration(seconds: 1)); // UX pause
        emit(BusinessAnalyticsLoaded(currentState.analytics)); // back
      } catch (e) {
        emit(
          BusinessAnalyticsDownloadError(currentState.analytics, e.toString()),
        );
        await Future.delayed(const Duration(seconds: 2)); // UX pause
        emit(BusinessAnalyticsLoaded(currentState.analytics)); // back
      }
    }
  }

  @override
  Future<void> close() async {
    await _rtSub?.cancel(); // stop ws listener
    _refreshDebounce?.cancel(); // stop debounce
    return super.close(); // parent close
  }
}
