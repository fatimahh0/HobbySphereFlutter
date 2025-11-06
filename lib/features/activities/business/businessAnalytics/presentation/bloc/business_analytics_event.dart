import 'package:equatable/equatable.dart';

abstract class BusinessAnalyticsEvent extends Equatable {
  const BusinessAnalyticsEvent();

  @override
  List<Object?> get props => [];
}

class LoadBusinessAnalytics extends BusinessAnalyticsEvent {
  final String token;
  final int businessId;

  const LoadBusinessAnalytics({
    required this.token,
    required this.businessId,
  });

  @override
  List<Object?> get props => [token, businessId];
}

class RefreshBusinessAnalytics extends BusinessAnalyticsEvent {
  final String token;
  final int businessId;

  const RefreshBusinessAnalytics({
    required this.token,
    required this.businessId,
  });

  @override
  List<Object?> get props => [token, businessId];
}

class DownloadAnalyticsReport extends BusinessAnalyticsEvent {
  final String token;
  final int businessId;

  const DownloadAnalyticsReport({
    required this.token,
    required this.businessId,
  });

  @override
  List<Object?> get props => [token, businessId];
}
