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

  String _status = 'Pending';

  TicketsBloc({
    required this.token,
    required this.getByStatus,
    required this.cancelTicket,
    required this.deleteTicket,
  }) : super(TicketsLoading('Pending')) {
    on<TicketsTabChanged>(_onTab);
    on<TicketsRefresh>(_onRefresh);
    on<TicketsCancelRequested>(_onCancel);
    on<TicketsDeleteRequested>(_onDelete);

    add(TicketsTabChanged(_status));
  }
  // lib/features/activities/user/tickets/presentation/bloc/tickets_bloc.dart

  Future<void> _load(Emitter<TicketsState> emit) async {
    emit(TicketsLoading(_status));
    try {
      final list = await getByStatus(token, _status);

      final filtered = switch (_status) {
        'Pending' => list.where(
          (b) =>
              b.bookingStatus == 'Pending' ||
              b.bookingStatus == 'CancelRequested',
        ),
        'Completed' => list.where((b) => b.bookingStatus == 'Completed'),
        'Canceled' => list.where((b) => b.bookingStatus == 'Canceled'),
        _ => list,
      }.toList(growable: false);

      emit(TicketsLoaded(_status, filtered));
    } catch (e) {
      emit(TicketsError(_status, e.toString()));
    }
  }

  Future<void> _onTab(TicketsTabChanged e, Emitter<TicketsState> emit) async {
    _status = e.status;
    await _load(emit);
  }

  Future<void> _onRefresh(TicketsRefresh e, Emitter<TicketsState> emit) async {
    await _load(emit);
  }

  Future<void> _onCancel(
    TicketsCancelRequested e,
    Emitter<TicketsState> emit,
  ) async {
    // optimistic overlay
    if (state is TicketsLoaded) {
      final s = state as TicketsLoaded;
      emit(TicketsLoaded(_status, s.tickets, actionInFlight: true));
    }
    try {
      await cancelTicket(token, e.bookingId, e.reason);
      await _load(emit); // reload Pending + Canceled on UI-level if needed
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
