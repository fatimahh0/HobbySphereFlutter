// ===== Flutter 3.35.x =====
// CreateItemState — uses your real domain models (ItemType, Currency)
// so Bloc/UI can pass List<ItemType> without casting.

import 'dart:io';
import 'package:equatable/equatable.dart';

// ⬇️ Use your actual entities returned by the use cases:
import 'package:hobby_sphere/features/activities/common/domain/entities/item_type.dart';
import 'package:hobby_sphere/features/activities/common/domain/entities/currency.dart';

class CreateItemState extends Equatable {
  // ===== identity =====
  final int? businessId; // business id

  // ===== form fields =====
  final String name; // activity name
  final int? itemTypeId; // selected type id
  final String description; // description
  final String address; // address
  final double? lat; // latitude
  final double? lng; // longitude
  final int? maxParticipants; // capacity
  final double? price; // price
  final DateTime? start; // start time
  final DateTime? end; // end time
  final File? image; // picked image file
  final String? imageUrl; // retained image url

  // ===== lookups (REAL MODELS) =====
  final List<ItemType> types; // item types
  final Currency? currency; // current currency

  // ===== ui =====
  final bool loading; // loading flag
  final String? error; // error text
  final String? success; // success text

  // ===== stripe =====
  final bool stripeConnected; // connected to Stripe?

  const CreateItemState({
    // identity
    this.businessId,

    // form
    this.name = '',
    this.itemTypeId,
    this.description = '',
    this.address = '',
    this.lat,
    this.lng,
    this.maxParticipants,
    this.price,
    this.start,
    this.end,
    this.image,
    this.imageUrl,

    // lookups
    this.types = const [],
    this.currency,

    // ui
    this.loading = false,
    this.error,
    this.success,

    // stripe
    this.stripeConnected = false,
  });

  // basic "ready" validation (Stripe checked separately)
  bool get ready {
    final okBasics =
        name.trim().isNotEmpty &&
        itemTypeId != null &&
        description.trim().isNotEmpty;
    final okLoc = address.trim().isNotEmpty && lat != null && lng != null;
    final okMeta =
        maxParticipants != null && maxParticipants! > 0 && price != null;
    final okDates = start != null && end != null;
    return okBasics && okLoc && okMeta && okDates;
  }

  CreateItemState copyWith({
    int? businessId,
    String? name,
    int? itemTypeId,
    String? description,
    String? address,
    double? lat,
    double? lng,
    int? maxParticipants,
    double? price,
    DateTime? start,
    DateTime? end,
    File? image,
    String? imageUrl,
    List<ItemType>? types, // ⬅️ now List<ItemType>
    Currency? currency, // ⬅️ now Currency
    bool? loading,
    String? error,
    String? success,
    bool? stripeConnected,
  }) {
    return CreateItemState(
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      itemTypeId: itemTypeId ?? this.itemTypeId,
      description: description ?? this.description,
      address: address ?? this.address,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      price: price ?? this.price,
      start: start ?? this.start,
      end: end ?? this.end,
      image: image ?? this.image,
      imageUrl: imageUrl ?? this.imageUrl,
      types: types ?? this.types, // ⬅️ List<ItemType>
      currency: currency ?? this.currency, // ⬅️ Currency
      loading: loading ?? this.loading,
      error: error,
      success: success,
      stripeConnected: stripeConnected ?? this.stripeConnected,
    );
  }

  @override
  List<Object?> get props => [
    businessId,
    name,
    itemTypeId,
    description,
    address,
    lat,
    lng,
    maxParticipants,
    price,
    start,
    end,
    image,
    imageUrl,
    types, // ⬅️ List<ItemType>
    currency, // ⬅️ Currency
    loading,
    error,
    success,
    stripeConnected,
  ];
}
