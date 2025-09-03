// ===== Flutter 3.35.x =====
// BusinessBookingBloc — handles loading, filtering, and updating bookings.

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../services/token_store.dart';
import '../../domain/usecases/get_business_bookings.dart';
import '../../domain/usecases/update_booking_status.dart';
import 'business_booking_event.dart';
import 'business_booking_state.dart';

class BusinessBookingBloc
    extends Bloc<BusinessBookingEvent, BusinessBookingState> {
  // Use cases from domain layer
  final GetBusinessBookings getBookings;
  final UpdateBookingStatus updateStatus;

  // Named params constructor (cleaner than positional)
  BusinessBookingBloc({required this.getBookings, required this.updateStatus})
    : super(const BusinessBookingState()) {
    // ✅ now state is never null
    on<BusinessBookingBootstrap>(_onBootstrap);
    on<BusinessBookingFilterChanged>(_onFilterChanged);
    on<RejectBooking>(_onRejectBooking);
    on<UnrejectBooking>(_onUnrejectBooking);
    on<MarkPaidBooking>(_onMarkPaidBooking);
  }

  // ===== Event Handlers =====

  Future<void> _onBootstrap(
    BusinessBookingBootstrap event,
    Emitter<BusinessBookingState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      // 1. Read saved token from TokenStore
      final auth = await TokenStore.read();
      final token = auth.token ?? '';

      // 2. Pass token to the usecase
      final bookings = await getBookings(token);

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

  Future<void> _onRejectBooking(
    RejectBooking event,
    Emitter<BusinessBookingState> emit,
  ) async {
    try {
      final auth = await TokenStore.read();
      final token = auth.token ?? '';
      await updateStatus(token, event.bookingId, 'Rejected');
      add(BusinessBookingBootstrap()); // reload
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onUnrejectBooking(
    UnrejectBooking event,
    Emitter<BusinessBookingState> emit,
  ) async {
    try {
      final auth = await TokenStore.read();
      final token = auth.token ?? '';
      await updateStatus(token, event.bookingId, 'Pending');
      add(BusinessBookingBootstrap()); // reload
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onMarkPaidBooking(
    MarkPaidBooking event,
    Emitter<BusinessBookingState> emit,
  ) async {
    try {
      final auth = await TokenStore.read();
      final token = auth.token ?? '';
      await updateStatus(token, event.bookingId, 'Paid');
      add(BusinessBookingBootstrap()); // reload
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
