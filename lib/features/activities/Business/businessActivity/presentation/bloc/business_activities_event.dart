// Flutter 3.35.x
// Events for BusinessActivitiesBloc (load list, delete item)

import 'package:equatable/equatable.dart'; // value equality

// Base class for all events
abstract class BusinessActivitiesEvent extends Equatable {
  const BusinessActivitiesEvent(); // const ctor
  @override
  List<Object?> get props => []; // no default props
}

// Load all activities for a business
class LoadBusinessActivities extends BusinessActivitiesEvent {
  final String token; // auth token
  final int businessId; // business id

  const LoadBusinessActivities({
    required this.token, // require token
    required this.businessId, // require id
  });

  @override
  List<Object?> get props => [token, businessId]; // compare fields
}

// Delete a single activity
class DeleteBusinessActivityEvent extends BusinessActivitiesEvent {
  final String token; // auth token
  final int id; // activity id

  const DeleteBusinessActivityEvent({
    required this.token, // require token
    required this.id, // require id
  });

  @override
  List<Object?> get props => [token, id]; // compare fields
}
