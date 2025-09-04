import 'package:equatable/equatable.dart';

abstract class BusinessActivitiesEvent extends Equatable {
  const BusinessActivitiesEvent();
  @override
  List<Object?> get props => [];
}

class LoadBusinessActivities extends BusinessActivitiesEvent {
  final String token;
  final int businessId;
  const LoadBusinessActivities({required this.token, required this.businessId});
}

class DeleteBusinessActivityEvent extends BusinessActivitiesEvent {
  final String token;
  final int id;
  const DeleteBusinessActivityEvent({required this.token, required this.id});
}
