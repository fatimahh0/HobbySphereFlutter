import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/services/token_store.dart';
import '../../domain/usecases/edit_item.dart';

import '../../domain/entities/edit_item_request.dart';
import 'edit_item_event.dart';
import 'edit_item_state.dart';
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_item_types.dart';
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_current_currency.dart';
import 'package:hobby_sphere/features/activities/Business/common/domain/usecases/get_business_activity_by_id.dart';

class EditItemBloc extends Bloc<EditItemEvent, EditItemState> {
  final UpdateItem updateItem;
  final GetItemTypes getItemTypes;
  final GetCurrentCurrency getCurrentCurrency;
  final GetBusinessActivityById getItemById; // to prefill
  final int businessId;

  EditItemBloc({
    required this.updateItem,
    required this.getItemTypes,
    required this.getCurrentCurrency,
    required this.getItemById,
    required this.businessId,
  }) : super(EditItemState(businessId: businessId)) {
    on<EditItemBootstrap>(_onBootstrap);
    on<EditItemNameChanged>((e, emit) => emit(state.copyWith(name: e.name)));
    on<EditItemTypeChanged>(
      (e, emit) => emit(state.copyWith(itemTypeId: e.typeId)),
    );
    on<EditItemDescriptionChanged>(
      (e, emit) => emit(state.copyWith(description: e.description)),
    );
    on<EditItemLocationPicked>(
      (e, emit) =>
          emit(state.copyWith(address: e.address, lat: e.lat, lng: e.lng)),
    );
    on<EditItemMaxChanged>(
      (e, emit) => emit(state.copyWith(maxParticipants: e.max)),
    );
    on<EditItemPriceChanged>((e, emit) => emit(state.copyWith(price: e.price)));
    on<EditItemStartChanged>((e, emit) => emit(state.copyWith(start: e.dt)));
    on<EditItemEndChanged>((e, emit) => emit(state.copyWith(end: e.dt)));
    on<EditItemImagePicked>(
      (e, emit) => emit(state.copyWith(image: e.image, imageRemoved: false)),
    );
    on<EditItemImageRemovedToggled>(
      (e, emit) => emit(
        state.copyWith(
          imageRemoved: e.removed,
          image: e.removed ? null : state.image,
        ),
      ),
    );
    on<EditItemSubmitPressed>(_onSubmit);
  }

  Future<void> _onBootstrap(
    EditItemBootstrap e,
    Emitter<EditItemState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null, success: null));
    try {
      final auth = await TokenStore.read();
      final token = auth.token ?? '';
      final types = await getItemTypes(token);
      final currency = await getCurrentCurrency(token);
      final item = await getItemById(token: token, id: e.itemId);

      // ---- robust price parse (handles BigDecimal/double/string) ----
      double _asDouble(Object? v) {
        if (v == null) return 0.0;
        if (v is num) return v.toDouble();
        return double.tryParse(v.toString()) ?? 0.0;
      }

      // ---- robust datetime (in case your usecase returns strings) ----
      DateTime? _asDateTime(Object? v) {
        if (v == null) return null;
        if (v is DateTime) return v;
        return DateTime.tryParse(v.toString());
      }

     
      emit(
        state.copyWith(
          loading: false,
          types: types,
          currency: currency,
          id: item.id,
          name: item.name ?? '',
          itemTypeId: item.itemTypeId,
          description: item.description ?? '',
          address: item.location ?? '',
          lat: item.latitude,
          lng: item.longitude,
          maxParticipants: item.maxParticipants,
          price: _asDouble(item.price),
          start: _asDateTime(item.startDate),
          end: _asDateTime(item.endDate),
          imageUrl: item.imageUrl,
          status: item.status ?? 'Upcoming',
        ),
      );
    } catch (err) {
      emit(state.copyWith(loading: false, error: err.toString()));
    }
  }

  Future<void> _onSubmit(
    EditItemSubmitPressed event,
    Emitter<EditItemState> emit,
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

      // same auto-status logic as Create
      final now = DateTime.now();
      final computedStatus = (state.start != null && state.start!.isAfter(now))
          ? 'Upcoming'
          : 'Active';

      final msg = await updateItem(
        token: token,
        req: EditItemRequest(
          id: state.id!,
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
          status: computedStatus,
          businessId: state.businessId!,
          image: state.image,
          imageRemoved: state.imageRemoved,
        ),
      );

      emit(state.copyWith(loading: false, success: msg));
    } catch (err) {
      emit(state.copyWith(loading: false, error: err.toString()));
    }
  }
}
