import 'package:equatable/equatable.dart';
import 'package:hobby_sphere/features/activities/business/common/domain/entities/business_activity.dart';

class BusinessHomeState extends Equatable {
  final List<BusinessActivity> items;
  final bool loading;
  final bool refreshing;
  final String currency; // e.g., "CAD"
  final String? message; // transient UI message
  final String? error; // transient UI error

  const BusinessHomeState({
    this.items = const [],
    this.loading = false,
    this.refreshing = false,
    this.currency = 'CAD',
    this.message,
    this.error,
  });

  BusinessHomeState copyWith({
    List<BusinessActivity>? items,
    bool? loading,
    bool? refreshing,
    String? currency,
    String? message, // pass null to clear
    String? error, // pass null to clear
  }) {
    return BusinessHomeState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
      currency: currency ?? this.currency,
      message: message,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    items,
    loading,
    refreshing,
    currency,
    message,
    error,
  ];
}
