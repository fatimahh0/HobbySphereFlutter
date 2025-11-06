// Flutter 3.35.x — BusinessActivityDetailsBloc
// Remember token/activity/businessId, emit local event after delete.

import 'package:flutter_bloc/flutter_bloc.dart'; // Bloc
import 'business_activity_details_event.dart'; // events
import 'business_activity_details_state.dart'; // states
import 'package:hobby_sphere/features/activities/business/common/domain/usecases/get_business_activity_by_id.dart';
import 'package:hobby_sphere/features/activities/business/common/domain/usecases/delete_business_activity.dart';

// ⬇️ NEW: realtime bus + event model
import 'package:hobby_sphere/core/realtime/realtime_bus.dart'; // send realtime events
import 'package:hobby_sphere/core/realtime/event_models.dart'; // RealtimeEvent + enums

class BusinessActivityDetailsBloc
    extends Bloc<BusinessActivityDetailsEvent, BusinessActivityDetailsState> {
  final GetBusinessActivityById getById; // loader
  final DeleteBusinessActivity deleteActivity; // deleter

  // ⬇️ NEW: keep some context for emit after delete
  late String _token; // current token
  late int _activityId; // current item id
  int _businessId = 0; // current business id (filled on load)

  BusinessActivityDetailsBloc({
    required this.getById,
    required this.deleteActivity,
  }) : super(BusinessActivityDetailsLoading()) {
    on<BusinessActivityDetailsRequested>(_onRequested); // load details
    on<BusinessActivityDetailsDeleteRequested>(_onDelete); // delete
  }

  Future<void> _onRequested(
    BusinessActivityDetailsRequested event,
    Emitter<BusinessActivityDetailsState> emit,
  ) async {
    _token = event.token; // remember token
    _activityId = event.id; // remember id
    emit(BusinessActivityDetailsLoading()); // busy
    try {
      final activity = await getById(token: _token, id: _activityId); // fetch
      _businessId = activity.businessId ?? _businessId; // remember business id
      emit(BusinessActivityDetailsLoaded(activity)); // show
    } catch (e) {
      emit(BusinessActivityDetailsError(e.toString())); // error
    }
  }

  Future<void> _onDelete(
    BusinessActivityDetailsDeleteRequested event,
    Emitter<BusinessActivityDetailsState> emit,
  ) async {
    try {
      await deleteActivity(
        token: event.token,
        id: event.activityId,
      ); // backend delete

      // 🔔 NEW: emit local realtime event so lists refresh instantly
      RealtimeBus.I.emit(
        RealtimeEvent(
          eventId:
              'local-${DateTime.now().microsecondsSinceEpoch}', // unique id
          domain: Domain.activity, // activities
          action: ActionType.deleted, // deleted
          businessId: _businessId, // which business
          resourceId: event.activityId, // which item
          ts: DateTime.now(), // now
        ),
      );

      emit(const BusinessActivityDetailsDeleted()); // success state
    } catch (e) {
      emit(BusinessActivityDetailsError("Failed to delete: $e")); // error
    }
  }
}
