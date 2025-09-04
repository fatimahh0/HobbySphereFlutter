import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/businessActivity/presentation/bloc/business_activities_state';
import 'business_activities_event.dart';

import 'package:hobby_sphere/features/activities/Business/common/domain/usecases/get_business_activities.dart';
import 'package:hobby_sphere/features/activities/Business/common/domain/usecases/delete_business_activity.dart';

class BusinessActivitiesBloc
    extends Bloc<BusinessActivitiesEvent, BusinessActivitiesState> {
  final GetBusinessActivities getActivities;
  final DeleteBusinessActivity deleteActivity;

  BusinessActivitiesBloc({
    required this.getActivities,
    required this.deleteActivity,
  }) : super(BusinessActivitiesInitial()) {
    on<LoadBusinessActivities>(_onLoad);
    on<DeleteBusinessActivityEvent>(_onDelete);
  }

  Future<void> _onLoad(
    LoadBusinessActivities event,
    Emitter<BusinessActivitiesState> emit,
  ) async {
    try {
      emit(BusinessActivitiesLoading());
      final activities = await getActivities(
        businessId: event.businessId,
        token: event.token,
      );
      emit(BusinessActivitiesLoaded(activities));
    } catch (e) {
      emit(BusinessActivitiesError(e.toString()));
    }
  }

  Future<void> _onDelete(
    DeleteBusinessActivityEvent event,
    Emitter<BusinessActivitiesState> emit,
  ) async {
    try {
      if (state is BusinessActivitiesLoaded) {
        final current = (state as BusinessActivitiesLoaded).activities;
        await deleteActivity(token: event.token, id: event.id);
        final updated = current.where((a) => a.id != event.id).toList();
        emit(BusinessActivitiesLoaded(updated));
      }
    } catch (e) {
      emit(BusinessActivitiesError("Failed to delete: ${e.toString()}"));
    }
  }
}
