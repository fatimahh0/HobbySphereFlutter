// Flutter 3.35.x — Tickets BLoC (no changes needed for realtime)
// Keeps logic for loading/canceling/deleting; UI will trigger refresh on WS.

import 'package:flutter_bloc/flutter_bloc.dart'; // bloc base
import '../../../tickets/domain/usecases/get_tickets_by_status.dart'; // uc
import '../../../tickets/domain/usecases/cancel_ticket.dart'; // uc
import '../../../tickets/domain/usecases/delete_ticket.dart'; // uc
import 'tickets_event.dart'; // events
import 'tickets_state.dart'; // states

class TicketsBloc extends Bloc<TicketsEvent, TicketsState> {
  final String token; // auth token
  final GetTicketsByStatus getByStatus; // usecase to load by status
  final CancelTicket cancelTicket; // usecase to cancel booking
  final DeleteTicket deleteTicket; // usecase to delete booking

  // UI statuses we support (Pending | Completed | CancelRequested | Canceled)
  String _status = 'Pending'; // default

  TicketsBloc({
    required this.token, // pass token
    required this.getByStatus, // inject uc
    required this.cancelTicket, // inject uc
    required this.deleteTicket, // inject uc
  }) : super(const TicketsLoading('Pending')) {
    on<TicketsTabChanged>(_onTab); // change tab/status
    on<TicketsRefresh>(_onRefresh); // reload same status
    on<TicketsCancelRequested>(_onCancel); // cancel booking
    on<TicketsDeleteRequested>(_onDelete); // delete booking

    add(const TicketsTabChanged('Pending')); // load default on start
  }

  // internal loader (emits loading → loaded or error)
  Future<void> _load(Emitter<TicketsState> emit) async {
    emit(TicketsLoading(_status)); // show loader for current status
    try {
      final list = await getByStatus(token, _status); // fetch from API

      // hard client filter to enforce exact buckets using .trim()
      final filtered = switch (_status.trim()) {
        'Pending' => list.where((b) => b.bookingStatus.trim() == 'Pending'),
        'Completed' => list.where((b) => b.bookingStatus.trim() == 'Completed'),
        'CancelRequested' => list.where(
          (b) => b.bookingStatus.trim() == 'CancelRequested',
        ),
        'Canceled' => list.where((b) => b.bookingStatus.trim() == 'Canceled'),
        _ => list,
      }.toList(growable: false);

      emit(TicketsLoaded(_status, filtered)); // success
    } catch (e) {
      emit(TicketsError(_status, e.toString())); // failure
    }
  }

  // handle status/tab change
  Future<void> _onTab(TicketsTabChanged e, Emitter<TicketsState> emit) async {
    _status = e.status.trim(); // set new status
    await _load(emit); // reload
  }

  // external refresh (pull-to-refresh / websocket)
  Future<void> _onRefresh(TicketsRefresh e, Emitter<TicketsState> emit) async {
    await _load(emit); // reload same status
  }

  // cancel flow
  Future<void> _onCancel(
    TicketsCancelRequested e,
    Emitter<TicketsState> emit,
  ) async {
    if (state is TicketsLoaded) {
      final s = state as TicketsLoaded; // keep current list
      emit(TicketsLoaded(_status, s.tickets, actionInFlight: true)); // spinner
    }
    try {
      await cancelTicket(token, e.bookingId, e.reason); // call API
      await _load(emit); // reload
    } catch (err) {
      emit(TicketsError(_status, err.toString())); // error
    }
  }

  // delete flow
  Future<void> _onDelete(
    TicketsDeleteRequested e,
    Emitter<TicketsState> emit,
  ) async {
    if (state is TicketsLoaded) {
      final s = state as TicketsLoaded; // keep current list
      emit(TicketsLoaded(_status, s.tickets, actionInFlight: true)); // spinner
    }
    try {
      await deleteTicket(token, e.bookingId); // call API
      await _load(emit); // reload
    } catch (err) {
      emit(TicketsError(_status, err.toString())); // error
    }
  }
}
