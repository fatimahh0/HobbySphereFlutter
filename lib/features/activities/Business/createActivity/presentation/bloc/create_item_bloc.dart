// Flutter 3.35.x
// CreateItemBloc — resilient bootstrap (each call protected with its own try/catch)

import 'dart:io'; // File
import 'package:flutter_bloc/flutter_bloc.dart'; // BLoC
import 'package:hobby_sphere/core/realtime/event_models.dart';
import 'package:hobby_sphere/core/realtime/realtime_bus.dart';
import 'package:http/http.dart' as http; // Download image
import 'package:hobby_sphere/core/network/globals.dart' as g; // server root
import 'package:hobby_sphere/services/token_store.dart'; // token

// Lookups
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_current_currency.dart';
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_item_types.dart';

// Create usecase + entity
import '../../domain/usecases/create_item.dart';
import '../../domain/entities/create_item_request.dart';

// ✅ Same Business repo used by BusinessProfile
import 'package:hobby_sphere/features/activities/Business/businessProfile/domain/repositories/business_repository.dart';

import 'create_item_event.dart';
import 'create_item_state.dart';

class CreateItemBloc extends Bloc<CreateItemEvent, CreateItemState> {
  final CreateItem createItem; // Create UC
  final GetItemTypes getItemTypes; // Types UC
  final GetCurrentCurrency getCurrentCurrency; // Currency UC
  final BusinessRepository businessRepo; // ✅ Stripe source of truth
  final int businessId; // Business id

  CreateItemBloc({
    required this.createItem, // inject
    required this.getItemTypes, // inject
    required this.getCurrentCurrency, // inject
    required this.businessRepo, // inject
    required this.businessId, // scope
  }) : super(CreateItemState(businessId: businessId)) {
    on<CreateItemBootstrap>(_onBootstrap); // load lists + stripe
    on<CreateItemRecheckStripe>(_onRecheckStripe); // refresh stripe only

    // simple setters
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
    on<CreateItemImageUrlRetained>(
      (e, emit) => emit(
        state.copyWith(imageUrl: e.imageUrl, error: null, success: null),
      ),
    );
    on<CreateItemImagePicked>(
      (e, emit) => emit(
        state.copyWith(
          image: e.image,
          imageUrl: e.image != null ? null : state.imageUrl,
        ),
      ),
    );

    on<CreateItemSubmitPressed>(_onSubmit); // submit
    on<CreateItemStartChanged>((e, emit) {
      emit(state.copyWith(start: e.dt)); // sets or clears (null ok)
    });

    on<CreateItemEndChanged>((e, emit) {
      emit(state.copyWith(end: e.dt)); // sets or clears (null ok)
    });
  }

  Future<void> _onBootstrap(
    CreateItemBootstrap e,
    Emitter<CreateItemState> emit,
  ) async {
    emit(
      state.copyWith(loading: true, error: null, success: null),
    ); // start spinner
    String? errMsg; // collect non-fatal errors
    try {
      final auth = await TokenStore.read(); // read auth
      final token = auth.token ?? ''; // token str

      // ---- 1) Load item types (safe) ----
      try {
        final types = await getItemTypes(token); // may 404
        emit(state.copyWith(types: types)); // set types if ok
      } catch (err) {
        errMsg = 'Failed to load item types.'; // remember error
        // keep going — don’t break bootstrap
      }

      // ---- 2) Load currency (safe) ----
      try {
        final currency = await getCurrentCurrency(token); // may fail
        emit(state.copyWith(currency: currency)); // set currency if ok
      } catch (err) {
        errMsg = (errMsg == null)
            ? 'Failed to load currency.'
            : '$errMsg • Failed to load currency.'; // accumulate
        // keep going
      }

      // ---- 3) Check Stripe (always attempt) ----
      bool connected = false; // default
      try {
        connected = await businessRepo.checkStripeStatus(
          token,
          businessId,
        ); // true/false
      } catch (err) {
        // If this fails, we keep connected=false but DO NOT overwrite with unrelated errors
        errMsg = (errMsg == null)
            ? 'Failed to check Stripe.'
            : '$errMsg • Failed to check Stripe.';
      }

      // ---- Final emit: stop loading + set stripe flag + show any soft errors ----
      emit(
        state.copyWith(
          loading: false, // stop spinner
          stripeConnected: connected, // real flag
          error: errMsg, // optional soft error
        ),
      );
    } catch (fatal) {
      // truly unexpected fatal error
      emit(
        state.copyWith(
          loading: false,
          stripeConnected: false,
          error: fatal.toString(),
        ),
      );
    }
  }

  Future<void> _onRecheckStripe(
    CreateItemRecheckStripe e,
    Emitter<CreateItemState> emit,
  ) async {
    try {
      final auth = await TokenStore.read(); // read token
      final token = auth.token ?? ''; // token
      final connected = await businessRepo.checkStripeStatus(
        token,
        businessId,
      ); // ask backend
      emit(
        state.copyWith(stripeConnected: connected, error: null),
      ); // update flag
    } catch (err) {
      emit(
        state.copyWith(error: 'Failed to refresh Stripe status.'),
      ); // soft error
    }
  }

  // (download helper + submit stay the same as your current version)
  Future<File> _downloadToTemp(String url) async {
    final res = await http.get(Uri.parse(url)); // GET
    if (res.statusCode != 200 || res.bodyBytes.isEmpty) {
      throw Exception('Failed to download image'); // guard
    }
    final file = File(
      '${Directory.systemTemp.path}/img_${DateTime.now().millisecondsSinceEpoch}.jpg',
    ); // temp
    await file.writeAsBytes(res.bodyBytes); // write
    return file; // file
  }

  Future<void> _onSubmit(
    CreateItemSubmitPressed e,
    Emitter<CreateItemState> emit,
  ) async {
    if (!state.stripeConnected) {
      emit(
        state.copyWith(error: 'Please connect your Stripe account first.'),
      ); // block
      return; // stop
    }
    if (!state.ready) {
      emit(state.copyWith(error: 'Please fill all required fields.')); // block
      return; // stop
    }
    if (state.start != null &&
        state.end != null &&
        !state.end!.isAfter(state.start!)) {
      emit(state.copyWith(error: 'End must be after Start.')); // block
      return; // stop
    }

    // Dates valid?
    if (state.start != null &&
        state.end != null &&
        !state.end!.isAfter(state.start!)) {
      emit(state.copyWith(error: 'End must be after Start.')); // message
      return; // stop
    }

    // Normalize retained image url (strip absolute root)
    String? normalizedUrl = state.imageUrl; // url
    if (normalizedUrl != null && normalizedUrl.isNotEmpty) {
      final base = g.serverRootNoApi(); // http://host:port
      if (base.isNotEmpty && normalizedUrl.startsWith(base)) {
        normalizedUrl = normalizedUrl.substring(base.length); // make relative
      }
      if (!normalizedUrl.startsWith('/')) {
        normalizedUrl = '/$normalizedUrl'; // ensure leading slash
      }
    }

    // Choose file to send
    File? imageFile = state.image; // prefer user picked

    // If no file but we have URL → try to download for better quality upload
    if (imageFile == null && (normalizedUrl?.isNotEmpty ?? false)) {
      final abs = normalizedUrl!.startsWith('http')
          ? normalizedUrl
          : '${g.serverRootNoApi()}$normalizedUrl'; // build absolute
      try {
        imageFile = await _downloadToTemp(abs); // get temp file
        normalizedUrl = null; // send as file only
      } catch (_) {
        // ignore (backend may accept imageUrl as fallback)
      }
    }

    // Call backend
    emit(state.copyWith(loading: true, error: null, success: null)); // spinner
    try {
      final auth = await TokenStore.read(); // read token
      final token = auth.token ?? ''; // token string

      // Compute status from start time
      final now = DateTime.now(); // now
      final computedStatus = (state.start != null && state.start!.isAfter(now))
          ? 'Upcoming'
          : 'Active'; // status

      // Build request entity
      final req = CreateItemRequest(
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
        image: imageFile, // file (nullable)
        imageUrl: normalizedUrl, // url (nullable)
      );

      // Execute use case
      final msg = await createItem(token: token, req: req); // server call

      // Optional: realtime event
      RealtimeBus.I.emit(
        RealtimeEvent(
          eventId:
              'local-${DateTime.now().microsecondsSinceEpoch}', // unique id
          domain: Domain.activity, // domain
          action: ActionType.created, // action
          businessId: state.businessId!, // id
          resourceId: 0, // unknown
          ts: DateTime.now(), // time
        ),
      );

      emit(state.copyWith(loading: false, success: msg)); // success
    } catch (err) {
      emit(state.copyWith(loading: false, error: err.toString())); // error
    }
  }
}
