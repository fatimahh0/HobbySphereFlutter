// Bloc – uses GetItemsByType
import 'package:flutter_bloc/flutter_bloc.dart'; // bloc
import '../../../domain/usecases/get_items_by_type.dart'; // usecase
import 'items_event.dart'; // event
import 'items_state.dart'; // state

class ItemsByTypeBloc extends Bloc<ItemsByTypeEvent, ItemsByTypeState> {
  final GetItemsByType getItems; // dependency
  ItemsByTypeBloc(this.getItems) : super(const ItemsByTypeInitial()) {
    on<ItemsByTypeLoadRequested>((event, emit) async {
      // load handler
      emit(const ItemsByTypeLoading()); // -> loading
      try {
        final list = await getItems(event.typeId); // fetch
        emit(ItemsByTypeLoaded(list)); // -> success
      } catch (e) {
        emit(ItemsByTypeError(e.toString())); // -> error
      }
    });
  }
}
