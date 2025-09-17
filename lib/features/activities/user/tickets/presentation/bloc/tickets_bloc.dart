import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../tickets/domain/usecases/get_tickets_by_status.dart';
import '../../../tickets/domain/usecases/cancel_ticket.dart';
import '../../../tickets/domain/usecases/delete_ticket.dart';
import 'tickets_event.dart';
import 'tickets_state.dart';

class TicketsBloc extends Bloc<TicketsEvent, TicketsState> {
  final String token;
  final GetTicketsByStatus getByStatus;
  final CancelTicket cancelTicket;
  final DeleteTicket deleteTicket;

  String _status =
      'Pending'; // UI values: Pending | Completed | CancelRequested | Canceled

  TicketsBloc({
    required this.token,
    required this.getByStatus,
    required this.cancelTicket,
    required this.deleteTicket,
  }) : super(const TicketsLoading('Pending')) {
    on<TicketsTabChanged>(_onTab);
    on<TicketsRefresh>(_onRefresh);
    on<TicketsCancelRequested>(_onCancel);
    on<TicketsDeleteRequested>(_onDelete);

    add(const TicketsTabChanged('Pending'));
  }

  Future<void> _load(Emitter<TicketsState> emit) async {
    emit(TicketsLoading(_status));
    try {
      final list = await getByStatus(token, _status);

      // hard client-side filter
      final filtered = switch (_status.trim()) {
        'Pending' => list.where((b) => b.bookingStatus.trim() == 'Pending'),
        'Completed' => list.where((b) => b.bookingStatus.trim() == 'Completed'),
        'CancelRequested' => list.where(
          (b) => b.bookingStatus.trim() == 'CancelRequested',
        ),
        'Canceled' => list.where((b) => b.bookingStatus.trim() == 'Canceled'),
        _ => list,
      }.toList(growable: false);

      emit(TicketsLoaded(_status, filtered));
    } catch (e) {
      emit(TicketsError(_status, e.toString()));
    }
  }

  Future<void> _onTab(TicketsTabChanged e, Emitter<TicketsState> emit) async {
    _status = e.status.trim();
    await _load(emit);
  }

  Future<void> _onRefresh(TicketsRefresh e, Emitter<TicketsState> emit) async {
    await _load(emit);
  }

  Future<void> _onCancel(
    TicketsCancelRequested e,
    Emitter<TicketsState> emit,
  ) async {
    if (state is TicketsLoaded) {
      final s = state as TicketsLoaded;
      emit(TicketsLoaded(_status, s.tickets, actionInFlight: true));
    }
    try {
      await cancelTicket(token, e.bookingId, e.reason);
      await _load(emit);
    } catch (err) {
      emit(TicketsError(_status, err.toString()));
    }
  }

  Future<void> _onDelete(
    TicketsDeleteRequested e,
    Emitter<TicketsState> emit,
  ) async {
    if (state is TicketsLoaded) {
      final s = state as TicketsLoaded;
      emit(TicketsLoaded(_status, s.tickets, actionInFlight: true));
    }
    try {
      await deleteTicket(token, e.bookingId);
      await _load(emit);
    } catch (err) {
      emit(TicketsError(_status, err.toString()));
    }
  }
}
