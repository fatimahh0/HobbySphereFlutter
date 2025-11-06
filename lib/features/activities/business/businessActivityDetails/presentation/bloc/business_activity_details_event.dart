// lib/features/activities/Business/businessActivity/presentation/bloc/business_activity_details_event.dart
import 'package:equatable/equatable.dart';

abstract class BusinessActivityDetailsEvent extends Equatable {
  const BusinessActivityDetailsEvent();

  @override
  List<Object?> get props => [];
}

class BusinessActivityDetailsRequested extends BusinessActivityDetailsEvent {
  final String token;
  final int id;

  const BusinessActivityDetailsRequested({
    required this.token,
    required this.id,
  });

  @override
  List<Object?> get props => [token, id];
}


class BusinessActivityDetailsDeleteRequested
    extends BusinessActivityDetailsEvent {
  final String token;
  final int activityId;

  const BusinessActivityDetailsDeleteRequested({
    required this.token,
    required this.activityId,
  });

  @override
  List<Object?> get props => [token, activityId];
}
