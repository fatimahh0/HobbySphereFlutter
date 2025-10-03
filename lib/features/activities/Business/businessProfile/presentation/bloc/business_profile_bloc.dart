// Flutter 3.35.x
// BusinessProfileBloc — handles profile, visibility, status, delete, Stripe connect, and realtime.

import 'dart:async'; // StreamSubscription
import 'package:flutter_bloc/flutter_bloc.dart'; // BLoC core
import 'package:url_launcher/url_launcher_string.dart'; // open external URLs

// Usecases
import 'package:hobby_sphere/features/activities/Business/businessProfile/domain/usecases/check_stripe_status.dart'; // check stripe
import 'package:hobby_sphere/features/activities/Business/businessProfile/domain/usecases/delete_business.dart'; // delete business
import 'package:hobby_sphere/features/activities/Business/businessProfile/domain/usecases/get_business_by_id.dart'; // get business
import 'package:hobby_sphere/features/activities/Business/businessProfile/domain/usecases/update_business_status.dart'; // update status
import 'package:hobby_sphere/features/activities/Business/businessProfile/domain/usecases/update_business_visibility.dart'; // update visibility
import 'package:hobby_sphere/features/activities/Business/businessProfile/domain/usecases/create_stripe_connect_link.dart'; // NEW: create link

// Events/States
import 'business_profile_event.dart'; // events
import 'business_profile_state.dart'; // states

// Realtime bus
import 'package:hobby_sphere/core/realtime/realtime_bus.dart'; // realtime bus
import 'package:hobby_sphere/core/realtime/event_models.dart'; // realtime event models

class BusinessProfileBloc
    extends Bloc<BusinessProfileEvent, BusinessProfileState> {
  final GetBusinessById getBusinessById; // usecase to load business
  final UpdateBusinessVisibility
  updateBusinessVisibility; // usecase to toggle visibility
  final UpdateBusinessStatus updateBusinessStatus; // usecase to change status
  final DeleteBusiness deleteBusiness; // usecase to delete
  final CheckStripeStatus checkStripeStatus; // usecase to check stripe
  final CreateStripeConnectLink
  createStripeConnectLink; // NEW: usecase to create onboarding link

  String? _token; // last token (for realtime reload)
  int? _businessId; // last business id (for realtime reload)
  StreamSubscription<RealtimeEvent>? _rtSub; // realtime subscription

  BusinessProfileBloc({
    required this.getBusinessById, // inject
    required this.updateBusinessVisibility, // inject
    required this.updateBusinessStatus, // inject
    required this.deleteBusiness, // inject
    required this.checkStripeStatus, // inject
    required this.createStripeConnectLink, // NEW inject
  }) : super(BusinessProfileInitial()) {
    on<LoadBusinessProfile>(_onLoad); // bind load
    on<ToggleVisibility>(_onToggleVisibility); // bind visibility
    on<ChangeStatus>(_onChangeStatus); // bind status
    on<DeleteBusinessEvent>(_onDeleteBusiness); // bind delete
    on<CheckStripeStatusEvent>(_onCheckStripe); // bind stripe check
    on<ConnectStripePressed>(_onConnectStripePressed); // NEW bind connect

    // Realtime: reload when the same business profile changes
    _rtSub = RealtimeBus.I.stream.listen((e) {
      if (e.domain != Domain.profile) return; // only profile domain
      if (_token == null || _businessId == null) return; // need scope
      if (e.resourceId == _businessId) {
        add(LoadBusinessProfile(_token!, _businessId!)); // reload profile
      }
    });
  }

  // Load business + stripe status
  Future<void> _onLoad(LoadBusinessProfile e, Emitter emit) async {
    emit(BusinessProfileLoading()); // show loading
    try {
      _token = e.token; // remember token
      _businessId = e.businessId; // remember id
      final business = await getBusinessById(
        e.token,
        e.businessId,
      ); // fetch business
      final connected = await checkStripeStatus(
        e.token,
        e.businessId,
      ); // check stripe
      emit(
        BusinessProfileLoaded(business, stripeConnected: connected),
      ); // emit loaded
    } catch (err) {
      emit(BusinessProfileError(err.toString())); // emit error
    }
  }

  // Toggle visibility → reload
  Future<void> _onToggleVisibility(ToggleVisibility e, Emitter emit) async {
    try {
      await updateBusinessVisibility(
        e.token,
        e.businessId,
        e.isPublic,
      ); // call usecase
      add(LoadBusinessProfile(e.token, e.businessId)); // reload
    } catch (err) {
      emit(BusinessProfileError(err.toString())); // error
    }
  }

  // Change status → reload
  Future<void> _onChangeStatus(ChangeStatus e, Emitter emit) async {
    try {
      await updateBusinessStatus(
        e.token,
        e.businessId,
        e.status,
        password: e.password,
      ); // call usecase
      add(LoadBusinessProfile(e.token, e.businessId)); // reload
    } catch (err) {
      emit(BusinessProfileError(err.toString())); // error
    }
  }

  // Delete business → reset state
  Future<void> _onDeleteBusiness(DeleteBusinessEvent e, Emitter emit) async {
    try {
      await deleteBusiness(e.token, e.businessId, e.password); // call usecase
      emit(BusinessProfileInitial()); // reset
    } catch (err) {
      emit(BusinessProfileError(err.toString())); // error
    }
  }

  // Check stripe status only (no reload of whole business)
  Future<void> _onCheckStripe(CheckStripeStatusEvent e, Emitter emit) async {
    try {
      final connected = await checkStripeStatus(
        e.token,
        e.businessId,
      ); // ask backend
      if (state is BusinessProfileLoaded) {
        final s = state as BusinessProfileLoaded; // current loaded
        emit(
          BusinessProfileLoaded(s.business, stripeConnected: connected),
        ); // update flag
      }
    } catch (err) {
      emit(
        BusinessProfileError("Stripe check failed: ${err.toString()}"),
      ); // error
    }
  }

  // NEW: Create Stripe connect link → open in browser
  Future<void> _onConnectStripePressed(
    ConnectStripePressed e,
    Emitter emit,
  ) async {
    try {
      final url = await createStripeConnectLink(
        e.token,
        e.businessId,
      ); // get onboarding url
      final ok = await launchUrlString(
        url,
        mode: LaunchMode.externalApplication,
      ); // open externally
      if (!ok) {
        emit(
          BusinessProfileError('Could not open Stripe onboarding link.'),
        ); // show error
        return; // stop
      }
      // After returning from Stripe, trigger a status check from UI if needed
      // add(CheckStripeStatusEvent(e.token, e.businessId)); // optional immediate check
    } catch (err) {
      emit(
        BusinessProfileError('Stripe connect failed: ${err.toString()}'),
      ); // show error
    }
  }

  @override
  Future<void> close() async {
    await _rtSub?.cancel(); // stop realtime
    return super.close(); // close bloc
  }
}
