// BLoC that connects UI to use cases                                 // file role
import 'package:flutter_bloc/flutter_bloc.dart'; // bloc pkg
import '../../domain/usecases/get_user_activity_detail.dart'; // usecase
import '../../domain/usecases/check_user_availability.dart'; // usecase
import '../../domain/usecases/confirm_user_booking.dart'; // usecase
import 'user_activity_detail_event.dart'; // events
import 'user_activity_detail_state.dart'; // state

class UserActivityDetailBloc
    extends Bloc<UserActivityDetailEvent, UserActivityDetailState> {
  // class
  final GetUserActivityDetail getItem; // dep
  final CheckUserAvailability check; // dep
  final ConfirmUserBooking confirm; // dep

  UserActivityDetailBloc({
    // ctor
    required this.getItem, // inject
    required this.check, // inject
    required this.confirm, // inject
  }) : super(const UserActivityDetailState(loading: false)) {
    // init state
    on<UserActivityDetailStarted>(_onStarted); // register
    on<UserParticipantsChanged>(_onQty); // register
    on<UserCheckAvailabilityPressed>(_onCheck); // register
    on<UserConfirmBookingPressed>(_onConfirm); // register
  }

  Future<void> _onStarted(
    // load item
    UserActivityDetailStarted e, // event
    Emitter<UserActivityDetailState> emit, // emitter
  ) async {
    emit(
      state.copyWith(loading: true, imageBaseUrl: e.imageBaseUrl),
    ); // show spinner + save base
    try {
      final item = await getItem(e.itemId); // call usecase
      emit(state.copyWith(loading: false, item: item)); // set data
    } catch (err) {
      emit(state.copyWith(loading: false, error: '$err')); // set error
    }
  }

  void _onQty(
    UserParticipantsChanged e, // qty change
    Emitter<UserActivityDetailState> emit,
  ) {
    final v = e.value.clamp(1, 999); // guard
    emit(state.copyWith(participants: v, canBook: false)); // update
  }

  Future<void> _onCheck(
    // check seats
    UserCheckAvailabilityPressed e,
    Emitter<UserActivityDetailState> emit,
  ) async {
    final item = state.item; // need item
    if (item == null) return; // guard
    emit(state.copyWith(checking: true, error: null)); // start
    try {
      final ok = await check(
        // call usecase
        itemId: item.id,
        participants: state.participants,
        bearerToken: e.bearerToken,
      );
      emit(state.copyWith(checking: false, canBook: ok)); // set flag
    } catch (err) {
      emit(state.copyWith(checking: false, error: '$err')); // error
    }
  }

  Future<void> _onConfirm(
    // confirm booking
    UserConfirmBookingPressed e,
    Emitter<UserActivityDetailState> emit,
  ) async {
    final item = state.item; // need item
    if (item == null) return; // guard
    emit(state.copyWith(booking: true, error: null)); // start
    try {
      await confirm(
        // call usecase
        itemId: item.id,
        participants: state.participants,
        stripePaymentId: e.stripePaymentId,
        bearerToken: e.bearerToken,
      );
      emit(state.copyWith(booking: false, canBook: true)); // success
    } catch (err) {
      emit(state.copyWith(booking: false, error: '$err')); // error
    }
  }
}
