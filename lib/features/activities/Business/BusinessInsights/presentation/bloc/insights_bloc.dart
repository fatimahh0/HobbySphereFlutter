// Flutter 3.35.x
// Auto-refresh insights for the current item when any booking event arrives.

import 'dart:async'; // StreamSubscription
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/core/realtime/event_models.dart';
import 'package:hobby_sphere/core/realtime/realtime_bus.dart';
import '../../domain/entities/insight_booking.dart';
import '../../domain/usecases/get_business_bookings.dart';
import '../../domain/usecases/mark_booking_paid.dart';

part 'insights_event.dart';
part 'insights_state.dart';

// ⬇️ realtime imports

class InsightsBloc extends Bloc<InsightsEvent, InsightsState> {
  final GetBusinessBookings getBookings; // use case
  final MarkBookingPaid markPaid; // use case

  // ⬇️ remember current scope (to reload on realtime)
  String? _token;
  int? _itemId;

  // ⬇️ subscription
  StreamSubscription<RealtimeEvent>? _rtSub;

  InsightsBloc({required this.getBookings, required this.markPaid})
    : super(InsightsLoading()) {
    on<LoadInsights>(_onLoad);
    on<MarkAsPaid>(_onMarkPaid);

    // ⬇️ refresh when a booking changes (for the same item if we know it)
    _rtSub = RealtimeBus.I.stream.listen((e) {
      if (e.domain != Domain.booking) return; // only bookings
      if (_token == null || _itemId == null) return; // need scope set
      // optional filter by itemId if server sends it in 'data'
      final sameItem = (e.data?['itemId'] as int?) == null
          ? true // no itemId in event → just refresh
          : (e.data!['itemId'] as int) == _itemId; // match item
      if (sameItem) {
        add(LoadInsights(token: _token!, itemId: _itemId!)); // reload
      }
    });
  }

  Future<void> _onLoad(LoadInsights event, Emitter<InsightsState> emit) async {
    emit(InsightsLoading());
    try {
      _token = event.token; // remember token
      _itemId = event.itemId; // remember item
      final bookings = await getBookings(event.token, event.itemId);
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
      await markPaid(event.token, event.bookingId); // backend call
      final bookings = await getBookings(event.token, event.itemId);
      emit(InsightsLoaded(bookings)); // refresh
    } catch (e) {
      emit(InsightsError(e.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _rtSub?.cancel(); // cleanup
    return super.close();
  }
}
