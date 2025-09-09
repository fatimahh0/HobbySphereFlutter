// lib/features/activities/Business/businessActivity/presentation/bloc/business_activity_details_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'business_activity_details_event.dart';
import 'business_activity_details_state.dart';
import 'package:hobby_sphere/features/activities/Business/common/domain/usecases/get_business_activity_by_id.dart';
import 'package:hobby_sphere/features/activities/Business/common/domain/usecases/delete_business_activity.dart';

class BusinessActivityDetailsBloc
    extends Bloc<BusinessActivityDetailsEvent, BusinessActivityDetailsState> {
  final GetBusinessActivityById getById;
  final DeleteBusinessActivity deleteActivity; 

  BusinessActivityDetailsBloc({
    required this.getById,
    required this.deleteActivity,
  }) : super(BusinessActivityDetailsLoading()) {
    on<BusinessActivityDetailsRequested>(_onRequested);
    on<BusinessActivityDetailsDeleteRequested>(_onDelete); 
  }

  Future<void> _onRequested(
    BusinessActivityDetailsRequested event,
    Emitter<BusinessActivityDetailsState> emit,
  ) async {
    emit(BusinessActivityDetailsLoading());
    try {
      final activity = await getById(token: event.token, id: event.id);
      emit(BusinessActivityDetailsLoaded(activity));
    } catch (e) {
      emit(BusinessActivityDetailsError(e.toString()));
    }
  }

  Future<void> _onDelete(
    BusinessActivityDetailsDeleteRequested event,
    Emitter<BusinessActivityDetailsState> emit,
  ) async {
    try {
      await deleteActivity(token: event.token, id: event.activityId);
      emit(const BusinessActivityDetailsDeleted());
    } catch (e) {
      emit(BusinessActivityDetailsError("Failed to delete: $e"));
    }
  }
}
