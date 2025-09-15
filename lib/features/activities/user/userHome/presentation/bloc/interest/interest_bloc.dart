import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_interest_based_items.dart';
import 'interest_event.dart';
import 'interest_state.dart';

class InterestBloc extends Bloc<InterestEvent, InterestState> {
  final GetInterestBasedItems usecase;
  InterestBloc(this.usecase) : super(const InterestInitial()) {
    on<InterestLoadRequested>((event, emit) async {
      emit(const InterestLoading());
      try {
        final list = await usecase(token: event.token, userId: event.userId);
        emit(InterestLoaded(list));
      } catch (e) {
        emit(InterestError(e.toString()));
      }
    });
  }
}
