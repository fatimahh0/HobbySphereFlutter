import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/insight_booking.dart';
import '../../domain/usecases/get_business_bookings.dart';
import '../../domain/usecases/mark_booking_paid.dart';

part 'insights_event.dart';
part 'insights_state.dart';

class InsightsBloc extends Bloc<InsightsEvent, InsightsState> {
  final GetBusinessBookings getBookings;
  final MarkBookingPaid markPaid;

  InsightsBloc({required this.getBookings, required this.markPaid})
    : super(InsightsLoading()) {
    on<LoadInsights>(_onLoad);
    on<MarkAsPaid>(_onMarkPaid);
  }

  Future<void> _onLoad(LoadInsights event, Emitter<InsightsState> emit) async {
    emit(InsightsLoading());
    try {
      final bookings = await getBookings(event.token);
      emit(InsightsLoaded(bookings));
    } catch (e) {
      emit(InsightsError(e.toString()));
    }
  }

  Future<void> _onMarkPaid(
    MarkAsPaid event,
    Emitter<InsightsState> emit,
  ) async {
    try {
      await markPaid(event.token, event.bookingId);
      final bookings = await getBookings(event.token);
      emit(InsightsLoaded(bookings));
    } catch (e) {
      emit(InsightsError(e.toString()));
    }
  }
}
