// Flutter 3.35.x
// Auto-reload business profile when profile changes arrive.

import 'dart:async'; // StreamSubscription
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/domain/usecases/check_stripe_status.dart';
import '../../domain/usecases/delete_business.dart';
import '../../domain/usecases/get_business_by_id.dart';
import '../../domain/usecases/update_business_status.dart';
import '../../domain/usecases/update_business_visibility.dart';
import 'business_profile_event.dart';
import 'business_profile_state.dart';

// ⬇️ realtime imports
import 'package:hobby_sphere/core/realtime/realtime_bus.dart';
import 'package:hobby_sphere/core/realtime/event_models.dart';

class BusinessProfileBloc
    extends Bloc<BusinessProfileEvent, BusinessProfileState> {
  final GetBusinessById getBusinessById;
  final UpdateBusinessVisibility updateBusinessVisibility;
  final UpdateBusinessStatus updateBusinessStatus;
  final DeleteBusiness deleteBusiness;
  final CheckStripeStatus checkStripeStatus;

  // ⬇️ remember last params to reload on realtime
  String? _token;
  int? _businessId;

  // ⬇️ subscription
  StreamSubscription<RealtimeEvent>? _rtSub;

  BusinessProfileBloc({
    required this.getBusinessById,
    required this.updateBusinessVisibility,
    required this.updateBusinessStatus,
    required this.deleteBusiness,
    required this.checkStripeStatus,
  }) : super(BusinessProfileInitial()) {
    on<LoadBusinessProfile>(_onLoad);
    on<ToggleVisibility>(_onToggleVisibility);
    on<ChangeStatus>(_onChangeStatus);
    on<DeleteBusinessEvent>(_onDeleteBusiness);
    on<CheckStripeStatusEvent>(_onCheckStripe);

    // ⬇️ realtime: reload when same business profile changes
    _rtSub = RealtimeBus.I.stream.listen((e) {
      if (e.domain != Domain.profile) return; // only profile domain
      if (_token == null || _businessId == null) return; // need scope
      if (e.resourceId == _businessId) {
        add(LoadBusinessProfile(_token!, _businessId!)); // reload
      }
    });
  }

  Future<void> _onLoad(LoadBusinessProfile e, Emitter emit) async {
    emit(BusinessProfileLoading());
    try {
      _token = e.token; // remember token
      _businessId = e.businessId; // remember id
      final business = await getBusinessById(e.token, e.businessId);
      final connected = await checkStripeStatus(e.token, e.businessId);
      emit(BusinessProfileLoaded(business, stripeConnected: connected));
    } catch (err) {
      emit(BusinessProfileError(err.toString()));
    }
  }

  Future<void> _onToggleVisibility(ToggleVisibility e, Emitter emit) async {
    try {
      await updateBusinessVisibility(e.token, e.businessId, e.isPublic);
      add(LoadBusinessProfile(e.token, e.businessId));
    } catch (err) {
      emit(BusinessProfileError(err.toString()));
    }
  }

  Future<void> _onChangeStatus(ChangeStatus e, Emitter emit) async {
    try {
      await updateBusinessStatus(
        e.token,
        e.businessId,
        e.status,
        password: e.password,
      );
      add(LoadBusinessProfile(e.token, e.businessId));
    } catch (err) {
      emit(BusinessProfileError(err.toString()));
    }
  }

  Future<void> _onDeleteBusiness(DeleteBusinessEvent e, Emitter emit) async {
    try {
      await deleteBusiness(e.token, e.businessId, e.password);
      emit(BusinessProfileInitial());
    } catch (err) {
      emit(BusinessProfileError(err.toString()));
    }
  }

  Future<void> _onCheckStripe(CheckStripeStatusEvent e, Emitter emit) async {
    try {
      final connected = await checkStripeStatus(e.token, e.businessId);
      if (state is BusinessProfileLoaded) {
        final current = state as BusinessProfileLoaded;
        emit(
          BusinessProfileLoaded(current.business, stripeConnected: connected),
        );
      }
    } catch (err) {
      emit(BusinessProfileError("Stripe check failed: ${err.toString()}"));
    }
  }

  @override
  Future<void> close() async {
    await _rtSub?.cancel(); // cleanup
    return super.close();
  }
}
