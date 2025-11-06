
// ===== business_analytics_state.dart =====
import 'package:equatable/equatable.dart';
import 'package:hobby_sphere/features/activities/business/BusinessAnalytics/domain/entities/business_analytics.dart';

abstract class BusinessAnalyticsState extends Equatable {
  const BusinessAnalyticsState();

  @override
  List<Object?> get props => [];
}

class BusinessAnalyticsInitial extends BusinessAnalyticsState {}

class BusinessAnalyticsLoading extends BusinessAnalyticsState {}

class BusinessAnalyticsLoaded extends BusinessAnalyticsState {
  final BusinessAnalytics analytics;

  const BusinessAnalyticsLoaded(this.analytics);

  @override
  List<Object?> get props => [analytics];
}

class BusinessAnalyticsError extends BusinessAnalyticsState {
  final String message;

  const BusinessAnalyticsError(this.message);

  @override
  List<Object?> get props => [message];
}

class BusinessAnalyticsDownloading extends BusinessAnalyticsState {
  final BusinessAnalytics analytics;

  const BusinessAnalyticsDownloading(this.analytics);

  @override
  List<Object?> get props => [analytics];
}

class BusinessAnalyticsDownloadSuccess extends BusinessAnalyticsState {
  final BusinessAnalytics analytics;
  final String message;

  const BusinessAnalyticsDownloadSuccess(this.analytics, this.message);

  @override
  List<Object?> get props => [analytics, message];
}

class BusinessAnalyticsDownloadError extends BusinessAnalyticsState {
  final BusinessAnalytics analytics;
  final String error;

  const BusinessAnalyticsDownloadError(this.analytics, this.error);

  @override
  List<Object?> get props => [analytics, error];
}
