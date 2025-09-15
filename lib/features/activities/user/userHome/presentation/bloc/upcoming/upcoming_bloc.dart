import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_upcoming_guest_items.dart';
import 'upcoming_event.dart';
import 'upcoming_state.dart';

class UpcomingBloc extends Bloc<UpcomingEvent, UpcomingState> {
  final GetUpcomingGuestItems usecase;
  UpcomingBloc(this.usecase) : super(const UpcomingInitial()) {
    on<UpcomingLoadRequested>((event, emit) async {
      emit(const UpcomingLoading());
      try {
        final list = await usecase(typeId: event.typeId);
        emit(UpcomingLoaded(list));
      } catch (e) {
        emit(UpcomingError(e.toString()));
      }
    });
  }
}
