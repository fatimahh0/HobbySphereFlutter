// ===== Flutter 3.35.x =====
// CreateItemBloc — now checks Stripe in bootstrap and blocks submit if not connected.

import 'dart:io'; // File + temp dir
import 'package:flutter_bloc/flutter_bloc.dart'; // Bloc
import 'package:http/http.dart' as http; // download retained image
import 'package:hobby_sphere/core/network/globals.dart' as g; // serverRootNoApi
import 'package:hobby_sphere/services/token_store.dart'; // token store

// realtime (unchanged)
import 'package:hobby_sphere/core/realtime/realtime_bus.dart';
import 'package:hobby_sphere/core/realtime/event_models.dart';

// lookups usecases (existing)
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_current_currency.dart';
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_item_types.dart';

// create item usecase (existing)
import '../../domain/usecases/create_item.dart';
import '../../domain/entities/create_item_request.dart';

// ✅ stripe check usecase (reuse from Business module)
import 'package:hobby_sphere/features/activities/Business/businessProfile/domain/usecases/check_stripe_status.dart';

// bloc parts
import 'create_item_event.dart';
import 'create_item_state.dart';

class CreateItemBloc extends Bloc<CreateItemEvent, CreateItemState> {
  // ===== injected use cases =====
  final CreateItem createItem; // create item
  final GetItemTypes getItemTypes; // load types
  final GetCurrentCurrency getCurrentCurrency; // load currency
  final CheckStripeStatus checkStripeStatus; // ✅ check stripe connected

  // ===== scope =====
  final int businessId; // business id

  CreateItemBloc({
    required this.createItem, // inject create use case
    required this.getItemTypes, // inject types use case
    required this.getCurrentCurrency, // inject currency use case
    required this.checkStripeStatus, // inject stripe check use case
    required this.businessId, // inject business id
  }) : super(CreateItemState(businessId: businessId)) {
    // bootstrap
    on<CreateItemBootstrap>(_onBootstrap);

    // field changes (unchanged)
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
    on<CreateItemStartChanged>((e, emit) => emit(state.copyWith(start: e.dt)));
    on<CreateItemEndChanged>((e, emit) => emit(state.copyWith(end: e.dt)));

    // image handlers (unchanged)
    on<CreateItemImageUrlRetained>(
      (e, emit) => emit(
        state.copyWith(imageUrl: e.imageUrl, error: null, success: null),
      ),
    );
    on<CreateItemImagePicked>((e, emit) {
      // if a new file is picked, clear imageUrl; if null, keep old url
      emit(
        state.copyWith(
          image: e.image,
          imageUrl: e.image != null ? null : state.imageUrl,
        ),
      );
    });

    // submit
    on<CreateItemSubmitPressed>(_onSubmit);
  }

  Future<void> _onBootstrap(
    CreateItemBootstrap event,
    Emitter<CreateItemState> emit,
  ) async {
    // start loading
    emit(state.copyWith(loading: true, error: null, success: null));
    try {
      // read token
      final auth = await TokenStore.read(); // read auth
      final token = auth.token ?? ''; // token string

      // parallel (can be done in sequence too)
      final types = await getItemTypes(token); // get types
      final currency = await getCurrentCurrency(token); // get currency

      // ✅ check stripe connected for this business
      final connected = await checkStripeStatus(
        token,
        businessId,
      ); // true/false

      // stop loading and set data
      emit(
        state.copyWith(
          loading: false, // stop spinner
          types: types, // set types
          currency: currency, // set currency
          stripeConnected: connected, // set stripe flag
        ),
      );
    } catch (e) {
      // on error: keep stripeConnected = false (safe)
      emit(
        state.copyWith(
          loading: false,
          error: e.toString(),
          stripeConnected: false,
        ),
      );
    }
  }

  // download retained image to a temp file (if needed)
  Future<File> _downloadToTemp(String absoluteUrl) async {
    // parse url
    final uri = Uri.parse(absoluteUrl);
    // fetch bytes
    final res = await http.get(uri);
    // validate
    if (res.statusCode != 200 || res.bodyBytes.isEmpty) {
      throw Exception('Failed to download image');
    }
    // create temp file name
    final name = uri.pathSegments.isNotEmpty
        ? uri.pathSegments.last
        : 'img_${DateTime.now().millisecondsSinceEpoch}.jpg';
    // write to temp
    final file = File('${Directory.systemTemp.path}/$name');
    await file.writeAsBytes(res.bodyBytes);
    // return file
    return file;
  }

  Future<void> _onSubmit(
    CreateItemSubmitPressed event,
    Emitter<CreateItemState> emit,
  ) async {
    // ✅ hard-block if Stripe not connected
    if (!state.stripeConnected) {
      emit(
        state.copyWith(error: 'Please connect your Stripe account first.'),
      ); // show reason
      return; // stop
    }

    // validate fields
    if (!state.ready) {
      emit(
        state.copyWith(error: 'Please fill all required fields.'),
      ); // show error
      return; // stop
    }

    // validate dates
    if (state.start != null &&
        state.end != null &&
        !state.end!.isAfter(state.start!)) {
      emit(state.copyWith(error: 'End must be after Start.')); // show error
      return; // stop
    }

    // normalize retained image url (make relative if needed)
    String? normalizedUrl = state.imageUrl; // start with url
    if (normalizedUrl != null && normalizedUrl.isNotEmpty) {
      final base = g.serverRootNoApi(); // e.g. http://host:port
      if (base.isNotEmpty && normalizedUrl.startsWith(base)) {
        normalizedUrl = normalizedUrl.substring(base.length); // strip base
      }
      if (!normalizedUrl.startsWith('/')) {
        normalizedUrl = '/$normalizedUrl'; // ensure leading slash
      }
    }

    // choose image file to send
    File? imageFile = state.image; // prefer picked file

    // if no file but have url → try download to file
    if (imageFile == null && (normalizedUrl?.isNotEmpty ?? false)) {
      final abs = normalizedUrl!.startsWith('http')
          ? normalizedUrl // already absolute
          : '${g.serverRootNoApi()}$normalizedUrl'; // build absolute
      try {
        imageFile = await _downloadToTemp(abs); // download to temp file
        normalizedUrl = null; // send as file only
      } catch (_) {
        // ignore download fail — backend may accept imageUrl fallback
      }
    }

    // start loading
    emit(state.copyWith(loading: true, error: null, success: null));
    try {
      // read token
      final auth = await TokenStore.read(); // auth
      final token = auth.token ?? ''; // token

      // compute status based on start time
      final now = DateTime.now(); // now
      final computedStatus = (state.start != null && state.start!.isAfter(now))
          ? 'Upcoming'
          : 'Active';

      // call create item use case
      final msg = await createItem(
        token: token, // token
        req: CreateItemRequest(
          itemName: state.name, // name
          itemTypeId: state.itemTypeId!, // type id
          description: state.description, // desc
          location: state.address, // address
          latitude: state.lat!, // lat
          longitude: state.lng!, // lng
          maxParticipants: state.maxParticipants!, // cap
          price: state.price!, // price
          startDatetime: state.start!, // start
          endDatetime: state.end!, // end
          status: computedStatus, // status
          businessId: state.businessId!, // business id
          image: imageFile, // file
          imageUrl: normalizedUrl, // url if no file
        ),
      );

      // optional: emit local realtime event
      RealtimeBus.I.emit(
        RealtimeEvent(
          eventId:
              'local-${DateTime.now().microsecondsSinceEpoch}', // unique id
          domain: Domain.activity, // domain
          action: ActionType.created, // created
          businessId: state.businessId!, // business id
          resourceId: 0, // unknown id (server can push later)
          ts: DateTime.now(), // timestamp
        ),
      );

      // success
      emit(state.copyWith(loading: false, success: msg)); // done
    } catch (e) {
      // failure
      emit(state.copyWith(loading: false, error: e.toString())); // show error
    }
  }
}
