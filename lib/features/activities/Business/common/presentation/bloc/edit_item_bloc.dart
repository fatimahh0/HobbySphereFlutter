// Flutter 3.35.x — EditItemBloc
// Emit a local realtime event after successful update.

import 'package:flutter_bloc/flutter_bloc.dart'; // Bloc
import 'package:hobby_sphere/services/token_store.dart'; // token

// ⬇️ NEW: realtime bus + event model
import 'package:hobby_sphere/core/realtime/realtime_bus.dart'; // send realtime events
import 'package:hobby_sphere/core/realtime/event_models.dart'; // RealtimeEvent + enums

import '../../domain/usecases/edit_item.dart'; // use case
import '../../domain/entities/edit_item_request.dart'; // request
import 'edit_item_event.dart'; // events
import 'edit_item_state.dart'; // state
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_item_types.dart';
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_current_currency.dart';
import 'package:hobby_sphere/features/activities/Business/common/domain/usecases/get_business_activity_by_id.dart';

class EditItemBloc extends Bloc<EditItemEvent, EditItemState> {
  final UpdateItem updateItem; // use case
  final GetItemTypes getItemTypes; // types
  final GetCurrentCurrency getCurrentCurrency; // currency
  final GetBusinessActivityById getItemById; // prefill
  final int businessId; // scope

  EditItemBloc({
    required this.updateItem,
    required this.getItemTypes,
    required this.getCurrentCurrency,
    required this.getItemById,
    required this.businessId,
  }) : super(EditItemState(businessId: businessId)) {
    on<EditItemBootstrap>(_onBootstrap); // load initial data

    on<EditItemNameChanged>(
      (e, emit) => emit(state.copyWith(name: e.name)),
    ); // name
    on<EditItemTypeChanged>(
      (e, emit) => emit(state.copyWith(itemTypeId: e.typeId)),
    ); // type
    on<EditItemDescriptionChanged>(
      (e, emit) => emit(state.copyWith(description: e.description)),
    ); // desc
    on<EditItemLocationPicked>(
      (e, emit) =>
          emit(state.copyWith(address: e.address, lat: e.lat, lng: e.lng)),
    ); // geo
    on<EditItemMaxChanged>(
      (e, emit) => emit(state.copyWith(maxParticipants: e.max)),
    ); // max
    on<EditItemPriceChanged>(
      (e, emit) => emit(state.copyWith(price: e.price)),
    ); // price
    on<EditItemStartChanged>(
      (e, emit) => emit(state.copyWith(start: e.dt)),
    ); // start
    on<EditItemEndChanged>((e, emit) => emit(state.copyWith(end: e.dt))); // end
    on<EditItemImagePicked>(
      (e, emit) => emit(state.copyWith(image: e.image, imageRemoved: false)),
    ); // picked file
    on<EditItemImageRemovedToggled>(
      (e, emit) => emit(
        state.copyWith(
          imageRemoved: e.removed,
          image: e.removed ? null : state.image, // toggle remove
        ),
      ),
    );

    on<EditItemSubmitPressed>(_onSubmit); // submit
  }

  Future<void> _onBootstrap(
    EditItemBootstrap e,
    Emitter<EditItemState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null, success: null)); // busy
    try {
      final auth = await TokenStore.read(); // read token
      final token = auth.token ?? ''; // jwt
      final types = await getItemTypes(token); // load types
      final currency = await getCurrentCurrency(token); // load currency
      final item = await getItemById(token: token, id: e.itemId); // load item

      // robust casts
      double _asDouble(Object? v) =>
          v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0.0;
      DateTime? _asDateTime(Object? v) =>
          v is DateTime ? v : DateTime.tryParse(v?.toString() ?? '');

      // fill state
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
      emit(state.copyWith(loading: false, error: err.toString())); // error
    }
  }

  Future<void> _onSubmit(
    EditItemSubmitPressed event,
    Emitter<EditItemState> emit,
  ) async {
    // validate required
    if (!state.ready) {
      emit(state.copyWith(error: 'Please fill all required fields.'));
      return;
    }
    // validate date order
    if (state.start != null &&
        state.end != null &&
        !state.end!.isAfter(state.start!)) {
      emit(state.copyWith(error: 'End must be after Start.'));
      return;
    }

    emit(state.copyWith(loading: true, error: null, success: null)); // busy
    try {
      final auth = await TokenStore.read(); // read token
      final token = auth.token ?? ''; // jwt

      // auto status
      final now = DateTime.now();
      final computedStatus = (state.start != null && state.start!.isAfter(now))
          ? 'Upcoming'
          : 'Active';

      // call update
      final msg = await updateItem(
        token: token,
        req: EditItemRequest(
          id: state.id!,
          name: state.name,
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
          image: state.image, // optional new file
          imageRemoved: state.imageRemoved, // remove flag
        ),
      );

      // 🔔 NEW: emit local realtime event so UI refreshes instantly
      RealtimeBus.I.emit(
        RealtimeEvent(
          eventId:
              'local-${DateTime.now().microsecondsSinceEpoch}', // unique id
          domain: Domain.activity, // activities
          action: ActionType.updated, // updated
          businessId: state.businessId!, // which business
          resourceId: state.id!, // which item
          ts: DateTime.now(), // now
        ),
      );

      emit(state.copyWith(loading: false, success: msg)); // done
    } catch (err) {
      emit(state.copyWith(loading: false, error: err.toString())); // error
    }
  }
}
