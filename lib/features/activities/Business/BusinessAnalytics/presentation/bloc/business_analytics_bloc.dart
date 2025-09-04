// ===== business_analytics_bloc.dart =====
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessAnalytics/domain/usecases/get_business_analytics.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessAnalytics/presentation/bloc/business_analytics_event.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessAnalytics/presentation/bloc/business_analytics_state.dart';

class BusinessAnalyticsBloc
    extends Bloc<BusinessAnalyticsEvent, BusinessAnalyticsState> {
  final GetBusinessAnalytics getBusinessAnalytics;

  BusinessAnalyticsBloc({required this.getBusinessAnalytics})
    : super(BusinessAnalyticsInitial()) {
    on<LoadBusinessAnalytics>(_onLoadBusinessAnalytics);
    on<RefreshBusinessAnalytics>(_onRefreshBusinessAnalytics);
    on<DownloadAnalyticsReport>(_onDownloadAnalyticsReport);
  }

  Future<void> _onLoadBusinessAnalytics(
    LoadBusinessAnalytics event,
    Emitter<BusinessAnalyticsState> emit,
  ) async {
    try {
      emit(BusinessAnalyticsLoading());
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

        // Simulate PDF generation/download
        await Future.delayed(const Duration(seconds: 2));

        // TODO: Implement actual PDF generation and download
        // final pdfService = GetIt.instance<PdfGeneratorService>();
        // await pdfService.generateAnalyticsReport(currentState.analytics);

        emit(
          BusinessAnalyticsDownloadSuccess(
            currentState.analytics,
            'Report downloaded successfully',
          ),
        );

        // Return to loaded state after showing success
        await Future.delayed(const Duration(seconds: 1));
        emit(BusinessAnalyticsLoaded(currentState.analytics));
      } catch (e) {
        emit(
          BusinessAnalyticsDownloadError(currentState.analytics, e.toString()),
        );

        // Return to loaded state after showing error
        await Future.delayed(const Duration(seconds: 2));
        emit(BusinessAnalyticsLoaded(currentState.analytics));
      }
    }
  }
}
