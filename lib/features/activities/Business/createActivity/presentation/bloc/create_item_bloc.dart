import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hobby_sphere/features/activities/common/domain/usecases/get_current_currency.dart';
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_item_types.dart';
import 'package:hobby_sphere/services/token_store.dart';
import '../../domain/usecases/create_item.dart';

import '../../domain/entities/create_item_request.dart';
import 'create_item_event.dart';
import 'create_item_state.dart';

class CreateItemBloc extends Bloc<CreateItemEvent, CreateItemState> {
  final CreateItem createItem;
  final GetItemTypes getItemTypes;
  final GetCurrentCurrency getCurrentCurrency;

  CreateItemBloc({
    required this.createItem,
    required this.getItemTypes,
    required this.getCurrentCurrency,
    required int businessId,
  }) : super(CreateItemState(businessId: businessId)) {
    on<CreateItemBootstrap>(_onBootstrap);
    on<CreateItemNameChanged>((e, emit) => emit(state.copyWith(name: e.name)));
    on<CreateItemTypeChanged>(
      (e, emit) => emit(state.copyWith(itemTypeId: e.typeId)),
    );
    on<CreateItemDescriptionChanged>(
      (e, emit) => emit(state.copyWith(description: e.description)),
    );
    on<CreateItemLocationPicked>(
      (e, emit) =>
          emit(state.copyWith(address: e.address, lat: e.lat, lng: e.lng)),
    );
    on<CreateItemMaxChanged>(
      (e, emit) => emit(state.copyWith(maxParticipants: e.max)),
    );
    on<CreateItemPriceChanged>(
      (e, emit) => emit(state.copyWith(price: e.price)),
    );
    on<CreateItemStartChanged>((e, emit) {
      emit(state.copyWith(start: e.dt)); // e.dt can be null → clear
    });

    on<CreateItemEndChanged>((e, emit) {
      emit(state.copyWith(end: e.dt)); // e.dt can be null → clear
    });

    on<CreateItemImagePicked>(
      (e, emit) => emit(state.copyWith(image: e.image)),
    );
    on<CreateItemSubmitPressed>(_onSubmit);
  }

  Future<void> _onBootstrap(
    CreateItemBootstrap event,
    Emitter<CreateItemState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null, success: null));
    try {
      final auth = await TokenStore.read();
      final token = auth.token ?? '';
      final types = await getItemTypes(token);
      final currency = await getCurrentCurrency(token);
      emit(state.copyWith(loading: false, types: types, currency: currency));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> _onSubmit(
    CreateItemSubmitPressed event,
    Emitter<CreateItemState> emit,
  ) async {
    if (!state.ready) {
      emit(state.copyWith(error: 'Please fill all required fields.'));
      return;
    }
    if (state.start != null &&
        state.end != null &&
        !state.end!.isAfter(state.start!)) {
      emit(state.copyWith(error: 'End must be after Start.'));
      return;
    }

    emit(state.copyWith(loading: true, error: null, success: null));
    try {
      final auth = await TokenStore.read();
      final token = auth.token ?? '';

      //  auto status:
      final now = DateTime.now();
      final computedStatus = (state.start != null && state.start!.isAfter(now))
          ? 'Upcoming'
          : 'Active';

      final msg = await createItem(
        token: token,
        req: CreateItemRequest(
          itemName: state.name,
          itemTypeId: state.itemTypeId!,
          description: state.description,
          location: state.address,
          latitude: state.lat!,
          longitude: state.lng!,
          maxParticipants: state.maxParticipants!,
          price: state.price!,
          startDatetime: state.start!,
          endDatetime: state.end!,
          status: computedStatus, // ✅ here
          businessId: state.businessId!,
          image: state.image,
        ),
      );

      emit(state.copyWith(loading: false, success: msg));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}
