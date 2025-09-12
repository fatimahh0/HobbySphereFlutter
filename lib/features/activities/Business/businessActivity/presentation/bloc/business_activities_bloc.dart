// Flutter 3.35.x
// Auto-refresh business activities when any activity event (create/update/delete/reopen) arrives.

import 'dart:async'; // StreamSubscription
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/businessActivity/presentation/bloc/business_activities_state';
import 'business_activities_event.dart';

import 'package:hobby_sphere/features/activities/Business/common/domain/usecases/get_business_activities.dart';
import 'package:hobby_sphere/features/activities/Business/common/domain/usecases/delete_business_activity.dart';

// ⬇️ realtime imports
import 'package:hobby_sphere/core/realtime/realtime_bus.dart'; // global bus
import 'package:hobby_sphere/core/realtime/event_models.dart'; // RealtimeEvent

class BusinessActivitiesBloc
    extends Bloc<BusinessActivitiesEvent, BusinessActivitiesState> {
  final GetBusinessActivities getActivities; // use case: load list
  final DeleteBusinessActivity deleteActivity; // use case: delete one

  // ⬇️ remember last token/businessId so we can reload on realtime
  String? _token; // last used token
  int? _businessId; // last used business id

  // ⬇️ subscription to realtime bus
  StreamSubscription<RealtimeEvent>? _rtSub;

  BusinessActivitiesBloc({
    required this.getActivities,
    required this.deleteActivity,
  }) : super(BusinessActivitiesInitial()) {
    on<LoadBusinessActivities>(_onLoad); // load list
    on<DeleteBusinessActivityEvent>(_onDelete); // delete item

    // ⬇️ listen to realtime bus and reload if same business + activity domain
    _rtSub = RealtimeBus.I.stream.listen((e) {
      // ignore until we have a business id/token
      if (_token == null || _businessId == null) return;

      final sameBusiness = e.businessId == _businessId;
      final isActivity = e.domain == Domain.activity;

      if (isActivity && sameBusiness) {
        // simply reuse last params to reload list
        add(LoadBusinessActivities(token: _token!, businessId: _businessId!));
      }
    });
  }

  Future<void> _onLoad(
    LoadBusinessActivities event,
    Emitter<BusinessActivitiesState> emit,
  ) async {
    try {
      emit(BusinessActivitiesLoading()); // show loader
      _token = event.token; // remember token
      _businessId = event.businessId; // remember business id

      final activities = await getActivities(
        businessId: event.businessId,
        token: event.token,
      ); // fetch list

      emit(BusinessActivitiesLoaded(activities)); // show list
    } catch (e) {
      emit(BusinessActivitiesError(e.toString())); // show error
    }
  }

  Future<void> _onDelete(
    DeleteBusinessActivityEvent event,
    Emitter<BusinessActivitiesState> emit,
  ) async {
    try {
      if (state is BusinessActivitiesLoaded) {
        final current = (state as BusinessActivitiesLoaded).activities;
        await deleteActivity(token: event.token, id: event.id); // backend
        final updated = current.where((a) => a.id != event.id).toList();
        emit(BusinessActivitiesLoaded(updated)); // optimistic UI
      }
    } catch (e) {
      emit(BusinessActivitiesError("Failed to delete: ${e.toString()}"));
    }
  }

  @override
  Future<void> close() async {
    await _rtSub?.cancel(); // stop listening
    return super.close();
  }
}
