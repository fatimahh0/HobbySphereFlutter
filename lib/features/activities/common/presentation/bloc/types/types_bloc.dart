// Bloc – uses GetItemTypes(token)
import 'package:flutter_bloc/flutter_bloc.dart'; // bloc
import '../../../domain/usecases/get_item_types.dart'; // usecase
import 'types_event.dart'; // event
import 'types_state.dart'; // state

class TypesBloc extends Bloc<TypesEvent, TypesState> {
  final GetItemTypes getTypes; // dependency
  TypesBloc(this.getTypes) : super(const TypesInitial()) {
    // ctor + initial
    on<TypesLoadRequested>((event, emit) async {
      // handle load
      emit(const TypesLoading()); // -> loading
      try {
        final list = await getTypes(event.token); // fetch
        emit(TypesLoaded(list)); // -> success
      } catch (e) {
        emit(TypesError(e.toString())); // -> error
      }
    });
  }
}
