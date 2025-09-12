// Flutter 3.35.x
// Auto-refresh bookings when any booking event arrives.

import 'dart:async'; // StreamSubscription
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/services/token_store.dart';
import '../../domain/usecases/get_business_bookings.dart';
import '../../domain/usecases/update_booking_status.dart';
import 'business_booking_event.dart';
import 'business_booking_state.dart';
import '../../domain/entities/business_booking.dart';

// ⬇️ realtime imports
import 'package:hobby_sphere/core/realtime/realtime_bus.dart';
import 'package:hobby_sphere/core/realtime/event_models.dart';

class BusinessBookingBloc
    extends Bloc<BusinessBookingEvent, BusinessBookingState> {
  final GetBusinessBookings getBookings; // use case
  final UpdateBookingStatus updateStatus; // use case

  // ⬇️ subscription to realtime
  StreamSubscription<RealtimeEvent>? _rtSub;

  BusinessBookingBloc({required this.getBookings, required this.updateStatus})
    : super(const BusinessBookingState()) {
    on<BusinessBookingBootstrap>(_onBootstrap); // initial load
    on<BusinessBookingFilterChanged>(_onFilterChanged); // change tab
    on<RejectBooking>(_onRejectBooking);
    on<UnrejectBooking>(_onUnrejectBooking);
    on<MarkPaidBooking>(_onMarkPaidBooking);
    on<ApproveCancelBooking>(_onApproveCancelBooking);
    on<RejectCancelBooking>(_onRejectCancelBooking);
    on<BusinessBookingClearFlash>(_onClearFlash);

    // ⬇️ whenever a booking event arrives → refresh list
    _rtSub = RealtimeBus.I.stream.listen((e) {
      if (e.domain == Domain.booking) {
        add(BusinessBookingBootstrap()); // reload from server
      }
    });
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

  Future<bool> _serverReflects(
    int id,
    bool Function(BusinessBooking b) predicate,
  ) async {
    final bookings = await getBookings(await _token());
    final found = bookings.where((b) => b.id == id);
    if (found.isEmpty) return false;
    return predicate(found.first);
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

  Future<void> _doAction({
    required Emitter<BusinessBookingState> emit,
    required int id,
    required String action,
    required String newStatus,
    required String targetTab,
  }) async {
    _setBusy(emit, id, true);
    final before = state.bookings;
    final optimistic = _optimisticMove(id: id, newStatus: newStatus);
    emit(state.copyWith(bookings: optimistic, filter: targetTab));

    try {
      await updateStatus(await _token(), id, action);
      await _refresh(emit);
      emit(state.copyWith(success: 'ok', error: null));
    } catch (e) {
      final ok = await _serverReflects(
        id,
        (b) => b.status.trim().toLowerCase() == newStatus.toLowerCase(),
      );
      if (ok) {
        await _refresh(emit);
        emit(state.copyWith(success: 'ok', error: null));
      } else {
        emit(state.copyWith(bookings: before, error: e.toString()));
      }
    } finally {
      _setBusy(emit, id, false);
    }
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
    newStatus: state.filter,
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

  @override
  Future<void> close() async {
    await _rtSub?.cancel(); // cleanup
    return super.close();
  }
}
