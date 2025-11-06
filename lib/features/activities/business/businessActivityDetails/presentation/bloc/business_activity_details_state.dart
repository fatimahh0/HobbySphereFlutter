// lib/features/activities/Business/businessActivity/presentation/bloc/business_activity_details_state.dart
import 'package:equatable/equatable.dart';
import 'package:hobby_sphere/features/activities/Business/common/domain/entities/business_activity.dart';

abstract class BusinessActivityDetailsState extends Equatable {
  const BusinessActivityDetailsState();

  @override
  List<Object?> get props => [];
}

class BusinessActivityDetailsLoading extends BusinessActivityDetailsState {}

class BusinessActivityDetailsLoaded extends BusinessActivityDetailsState {
  final BusinessActivity activity;

  const BusinessActivityDetailsLoaded(this.activity);

  @override
  List<Object?> get props => [activity];
}

class BusinessActivityDetailsError extends BusinessActivityDetailsState {
  final String message;

  const BusinessActivityDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}

class BusinessActivityDetailsDeleted extends BusinessActivityDetailsState {
  const BusinessActivityDetailsDeleted();
}
