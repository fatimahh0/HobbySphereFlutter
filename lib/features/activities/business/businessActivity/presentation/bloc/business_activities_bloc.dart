// Flutter 3.35.x
// Auto-refresh business activities when any activity event (create/update/delete/reopen) arrives.

import 'dart:async'; // StreamSubscription for realtime
import 'package:flutter_bloc/flutter_bloc.dart'; // Bloc
import 'package:hobby_sphere/features/activities/business/businessActivity/presentation/bloc/business_activities_state';
import 'business_activities_event.dart'; // events

// Use cases (your domain layer)
import 'package:hobby_sphere/features/activities/business/common/domain/usecases/get_business_activities.dart'; // fetch list
import 'package:hobby_sphere/features/activities/business/common/domain/usecases/delete_business_activity.dart'; // delete item

// Realtime bus (global)
import 'package:hobby_sphere/core/realtime/realtime_bus.dart'; // bus singleton
import 'package:hobby_sphere/core/realtime/event_models.dart'; // RealtimeEvent + Domain

class BusinessActivitiesBloc
    extends Bloc<BusinessActivitiesEvent, BusinessActivitiesState> {
  final GetBusinessActivities getActivities; // use case: load list
  final DeleteBusinessActivity deleteActivity; // use case: delete one

  String? _token; // last token used (for refresh)
  int? _businessId; // last business id used (for refresh)

  StreamSubscription<RealtimeEvent>? _rtSub; // subscription to realtime

  BusinessActivitiesBloc({
    required this.getActivities, // inject load use case
    required this.deleteActivity, // inject delete use case
  }) : super(BusinessActivitiesInitial() /* start state */) {
    on<LoadBusinessActivities>(_onLoad); // handle load
    on<DeleteBusinessActivityEvent>(_onDelete); // handle delete

    // Listen to realtime events once (constructor)
    _rtSub = RealtimeBus.I.stream.listen((e) {
      // If we never loaded yet, skip
      if (_token == null || _businessId == null) return; // guard

      // Same business? (make sure event has businessId)
      final sameBusiness = e.businessId == _businessId; // compare ids

      // Only react to activity domain events
      final isActivity = e.domain == Domain.activity; // check domain

      // When activity event for same business -> reload list
      if (isActivity && sameBusiness) {
        add(
          LoadBusinessActivities(token: _token!, businessId: _businessId!),
        ); // dispatch reload
      }
    });
  }

  // Handle list loading
  Future<void> _onLoad(
    LoadBusinessActivities event,
    Emitter<BusinessActivitiesState> emit,
  ) async {
    try {
      emit(BusinessActivitiesLoading()); // show spinner

      _token = event.token; // remember token for refresh
      _businessId = event.businessId; // remember id for refresh

      // Call use case to fetch activities
      final activities = await getActivities(
        businessId: event.businessId, // id
        token: event.token, // auth
      );

      // If use case returns null, treat as empty
      final safeList = activities ?? <dynamic>[]; // null-safe
      // Emit loaded state with list (cast to correct type if needed)
      emit(BusinessActivitiesLoaded(List.from(safeList))); // show list
    } catch (e) {
      // If the error looks like "no data" (404), emit empty list instead of error
      final msg = e.toString().toLowerCase(); // normalize
      final looksLikeEmpty =
          msg.contains('404') ||
          msg.contains('not found') ||
          msg.contains('no activities'); // heuristics

      if (looksLikeEmpty) {
        emit(
          const BusinessActivitiesLoaded([]),
        ); // show empty state (no spinner)
      } else {
        emit(BusinessActivitiesError(e.toString())); // show real error
      }
    }
  }

  // Handle delete
  Future<void> _onDelete(
    DeleteBusinessActivityEvent event,
    Emitter<BusinessActivitiesState> emit,
  ) async {
    try {
      // Only proceed if we have a list already
      if (state is BusinessActivitiesLoaded) {
        final current =
            (state as BusinessActivitiesLoaded).activities; // current list
        await deleteActivity(token: event.token, id: event.id); // call backend
        final updated = current
            .where((a) => a.id != event.id)
            .toList(); // remove item locally
        emit(BusinessActivitiesLoaded(updated)); // optimistic update
      }
    } catch (e) {
      emit(
        BusinessActivitiesError('Failed to delete: ${e.toString()}'),
      ); // show error
    }
  }

  @override
  Future<void> close() async {
    await _rtSub?.cancel(); // stop listening to realtime
    return super.close(); // close bloc
  }
}
