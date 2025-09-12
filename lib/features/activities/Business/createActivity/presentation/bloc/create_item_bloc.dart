// Flutter 3.35.x — CreateItemBloc
// Emit a local realtime event after success (so lists/details refresh immediately).

import 'dart:io'; // File + temp dir
import 'package:flutter_bloc/flutter_bloc.dart'; // Bloc
import 'package:http/http.dart' as http; // Simple HTTP download
import 'package:hobby_sphere/core/network/globals.dart'
    as g; // serverRootNoApi()

// ⬇️ NEW: realtime bus + event model
import 'package:hobby_sphere/core/realtime/realtime_bus.dart'; // send realtime events
import 'package:hobby_sphere/core/realtime/event_models.dart'; // RealtimeEvent + enums

import 'package:hobby_sphere/features/activities/common/domain/usecases/get_current_currency.dart';
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_item_types.dart';
import 'package:hobby_sphere/services/token_store.dart';

import '../../domain/usecases/create_item.dart';
import '../../domain/entities/create_item_request.dart';

import 'create_item_event.dart';
import 'create_item_state.dart';

class CreateItemBloc extends Bloc<CreateItemEvent, CreateItemState> {
  final CreateItem createItem; // Use case to create item
  final GetItemTypes getItemTypes; // Loads types
  final GetCurrentCurrency getCurrentCurrency; // Loads currency

  CreateItemBloc({
    required this.createItem, // inject use case
    required this.getItemTypes, // inject types loader
    required this.getCurrentCurrency, // inject currency loader
    required int businessId, // business owner id
  }) : super(CreateItemState(businessId: businessId)) {
    on<CreateItemBootstrap>(_onBootstrap); // load dropdowns + currency

    on<CreateItemNameChanged>(
      (e, emit) => emit(state.copyWith(name: e.name)),
    ); // name
    on<CreateItemTypeChanged>(
      (e, emit) => emit(state.copyWith(itemTypeId: e.typeId)),
    ); // type
    on<CreateItemDescriptionChanged>(
      (e, emit) => emit(state.copyWith(description: e.description)),
    ); // desc
    on<CreateItemLocationPicked>(
      (e, emit) =>
          emit(state.copyWith(address: e.address, lat: e.lat, lng: e.lng)),
    ); // geo
    on<CreateItemMaxChanged>(
      (e, emit) => emit(state.copyWith(maxParticipants: e.max)),
    ); // max
    on<CreateItemPriceChanged>(
      (e, emit) => emit(state.copyWith(price: e.price)),
    ); // price
    on<CreateItemStartChanged>(
      (e, emit) => emit(state.copyWith(start: e.dt)),
    ); // start
    on<CreateItemEndChanged>(
      (e, emit) => emit(state.copyWith(end: e.dt)),
    ); // end

    on<CreateItemImageUrlRetained>(
      (e, emit) => emit(
        state.copyWith(
          imageUrl: e.imageUrl,
          error: null,
          success: null,
        ), // keep old url
      ),
    );

    on<CreateItemImagePicked>((e, emit) {
      // if user picked a file, prefer it and clear url; if null, keep old url
      emit(
        state.copyWith(
          image: e.image,
          imageUrl: e.image != null ? null : state.imageUrl,
        ),
      );
    });

    on<CreateItemSubmitPressed>(_onSubmit); // submit handler
  }

  Future<void> _onBootstrap(
    CreateItemBootstrap event,
    Emitter<CreateItemState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null, success: null)); // busy
    try {
      final auth = await TokenStore.read(); // read token
      final token = auth.token ?? ''; // jwt
      final types = await getItemTypes(token); // load types
      final currency = await getCurrentCurrency(token); // load currency
      emit(
        state.copyWith(loading: false, types: types, currency: currency),
      ); // done
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString())); // error
    }
  }

  // download existing image into a temp file so we can re-upload it as "image"
  Future<File> _downloadToTemp(String absoluteUrl) async {
    final uri = Uri.parse(absoluteUrl); // parse url
    final res = await http.get(uri); // GET bytes
    if (res.statusCode != 200 || res.bodyBytes.isEmpty) {
      throw Exception('Failed to download image'); // fail fast
    }
    final name = uri.pathSegments.isNotEmpty
        ? uri.pathSegments.last
        : 'reopen_${DateTime.now().millisecondsSinceEpoch}.jpg'; // fallback name
    final file = File('${Directory.systemTemp.path}/$name'); // temp path
    await file.writeAsBytes(res.bodyBytes); // save bytes
    return file; // return local file
  }

  Future<void> _onSubmit(
    CreateItemSubmitPressed event,
    Emitter<CreateItemState> emit,
  ) async {
    // validate required fields
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

    // keep normalized URL (relative to server) if present
    String? normalizedUrl = state.imageUrl;
    if (normalizedUrl != null && normalizedUrl.isNotEmpty) {
      final base = g.serverRootNoApi(); // http://host:port
      if (base.isNotEmpty && normalizedUrl.startsWith(base)) {
        normalizedUrl = normalizedUrl.substring(base.length); // make relative
      }
      if (!normalizedUrl.startsWith('/'))
        normalizedUrl = '/$normalizedUrl'; // ensure leading slash
    }

    // choose file to send
    File? imageFile = state.image; // new picked file if any

    // fallback: no new file but we have old url → download and re-upload as file
    if (imageFile == null && (normalizedUrl?.isNotEmpty ?? false)) {
      final abs = normalizedUrl!.startsWith('http')
          ? normalizedUrl // already absolute
          : '${g.serverRootNoApi()}$normalizedUrl'; // make absolute
      try {
        imageFile = await _downloadToTemp(abs); // download
        normalizedUrl = null; // send as file only
      } catch (e) {
        // ignore and keep normalizedUrl as fallback for backend
        // ignore: avoid_print
        print('fallback download failed: $e');
      }
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

      // send request
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
          status: computedStatus,
          businessId: state.businessId!,
          image: imageFile, // prefer real file
          imageUrl: normalizedUrl, // fallback url (only if no file)
        ),
      );

      // 🔔 NEW: emit local realtime event so UI refreshes instantly
      RealtimeBus.I.emit(
        RealtimeEvent(
          eventId:
              'local-${DateTime.now().microsecondsSinceEpoch}', // unique local id
          domain: Domain.activity, // activities domain
          action: ActionType.reopened, // or ActionType.created (your choice)
          businessId: state.businessId!, // which business changed
          resourceId: 0, // new id if backend returns it; else 0
          ts: DateTime.now(), // now
        ),
      );

      emit(state.copyWith(loading: false, success: msg)); // done
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString())); // error
    }
  }
}
