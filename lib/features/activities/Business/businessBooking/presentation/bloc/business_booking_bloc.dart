import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../services/token_store.dart';
import '../../domain/usecases/get_business_bookings.dart';
import '../../domain/usecases/update_booking_status.dart';
import 'business_booking_event.dart';
import 'business_booking_state.dart';
import '../../domain/entities/business_booking.dart';

class BusinessBookingBloc
    extends Bloc<BusinessBookingEvent, BusinessBookingState> {
  final GetBusinessBookings getBookings;
  final UpdateBookingStatus updateStatus;

  BusinessBookingBloc({required this.getBookings, required this.updateStatus})
    : super(const BusinessBookingState()) {
    on<BusinessBookingBootstrap>(_onBootstrap);
    on<BusinessBookingFilterChanged>(_onFilterChanged);
    on<RejectBooking>(_onRejectBooking);
    on<UnrejectBooking>(_onUnrejectBooking);
    on<MarkPaidBooking>(_onMarkPaidBooking);
    on<ApproveCancelBooking>(_onApproveCancelBooking);
    on<RejectCancelBooking>(_onRejectCancelBooking);
    on<BusinessBookingClearFlash>(_onClearFlash);
  }

  // ---------------- helpers ----------------

  Future<String> _token() async => (await TokenStore.read()).token ?? '';

  void _setBusy(Emitter<BusinessBookingState> emit, int id, bool value) {
    final s = state.busyIds.toSet();
    value ? s.add(id) : s.remove(id);
    emit(state.copyWith(busyIds: s));
  }

  BusinessBooking? _findLocal(int id) => state.bookings.firstWhere(
    (b) => b.id == id,
    orElse: () => null as BusinessBooking,
  );

  List<BusinessBooking> _optimisticMove({
    required int id,
    required String newStatus,
  }) {
    // update status locally so the item jumps right away
    final list = state.bookings.map((b) {
      if (b.id == id) {
        return BusinessBooking(
          id: b.id,
          status: newStatus,
          wasPaid: b.wasPaid,
          itemName: b.itemName,
          itemImage: b.itemImage,
          bookedBy: b.bookedBy,
          bookedByAvatar: b.bookedByAvatar,
          participants: b.participants,
          price: b.price,
          paymentMethod: b.paymentMethod,
          bookingDatetime: b.bookingDatetime,
          currency: b.currency,
        );
      }
      return b;
    }).toList();
    return list;
  }

  Future<void> _refresh(Emitter<BusinessBookingState> emit) async {
    final bookings = await getBookings(await _token());
    emit(state.copyWith(bookings: bookings));
  }

  // If API failed with 500, check server truth: if the booking now has target status, treat as success.
  Future<bool> _serverReflects(
    int id,
    bool Function(BusinessBooking b) predicate,
  ) async {
    final bookings = await getBookings(await _token());
    final found = bookings.where((b) => b.id == id);
    if (found.isEmpty) return false;
    return predicate(found.first);
  }

  // generic action with optimistic UI, single call, verify & rollback if needed
  Future<void> _doAction({
    required Emitter<BusinessBookingState> emit,
    required int id,
    required String
    action, // 'Rejected' | 'Pending' | 'Paid' | 'cancel_approved' | 'cancel_rejected'
    required String
    newStatus, // status we want to see in UI (same mapping as action)
    required String targetTab, // auto switch tab
  }) async {
    // 1) mark busy + optimistic move + switch tab instantly
    _setBusy(emit, id, true);
    final before = state.bookings; // for potential rollback
    final optimistic = _optimisticMove(id: id, newStatus: newStatus);
    emit(state.copyWith(bookings: optimistic, filter: targetTab));

    try {
      await updateStatus(await _token(), id, action); // single PUT

      // 2) refresh from server and finalize
      await _refresh(emit);
      emit(state.copyWith(success: 'ok', error: null));
    } catch (e) {
      // 3) server error → check if server actually applied it
      final ok = await _serverReflects(
        id,
        (b) => b.status.trim().toLowerCase() == newStatus.toLowerCase(),
      );

      if (ok) {
        // treat as success anyway
        await _refresh(emit);
        emit(state.copyWith(success: 'ok', error: null));
      } else {
        // rollback + show error
        emit(state.copyWith(bookings: before, error: e.toString()));
      }
    } finally {
      _setBusy(emit, id, false);
    }
  }

  // ---------------- handlers ----------------

  Future<void> _onBootstrap(
    BusinessBookingBootstrap event,
    Emitter<BusinessBookingState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final bookings = await getBookings(await _token());
      emit(state.copyWith(bookings: bookings, loading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), loading: false));
    }
  }

  void _onFilterChanged(
    BusinessBookingFilterChanged event,
    Emitter<BusinessBookingState> emit,
  ) {
    emit(state.copyWith(filter: event.filter));
  }

  void _onClearFlash(
    BusinessBookingClearFlash event,
    Emitter<BusinessBookingState> emit,
  ) {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }

  Future<void> _onRejectBooking(
    RejectBooking event,
    Emitter<BusinessBookingState> emit,
  ) async => _doAction(
    emit: emit,
    id: event.bookingId,
    action: 'Rejected',
    newStatus: 'Rejected',
    targetTab: 'rejected',
  );

  Future<void> _onUnrejectBooking(
    UnrejectBooking event,
    Emitter<BusinessBookingState> emit,
  ) async => _doAction(
    emit: emit,
    id: event.bookingId,
    action: 'Pending',
    newStatus: 'Pending',
    targetTab: 'pending',
  );

  Future<void> _onMarkPaidBooking(
    MarkPaidBooking event,
    Emitter<BusinessBookingState> emit,
  ) async => _doAction(
    emit: emit,
    id: event.bookingId,
    action: 'Paid',
    newStatus: state.filter, // not used by predicate; we keep same tab
    targetTab: state.filter,
  );

  Future<void> _onApproveCancelBooking(
    ApproveCancelBooking event,
    Emitter<BusinessBookingState> emit,
  ) async => _doAction(
    emit: emit,
    id: event.bookingId,
    action: 'cancel_approved',
    newStatus: 'Canceled',
    targetTab: 'canceled',
  );

  Future<void> _onRejectCancelBooking(
    RejectCancelBooking event,
    Emitter<BusinessBookingState> emit,
  ) async => _doAction(
    emit: emit,
    id: event.bookingId,
    action: 'cancel_rejected',
    newStatus: 'Rejected',
    targetTab: 'rejected',
  );
}
