// Flutter 3.35.x — patch CreateItemState to allow setting nulls explicitly
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:hobby_sphere/features/activities/common/domain/entities/item_type.dart';
import 'package:hobby_sphere/features/activities/common/domain/entities/currency.dart';

class CreateItemState extends Equatable {
  // ===== identity =====
  final int? businessId;
  // ===== form =====
  final String name;
  final int? itemTypeId;
  final String description;
  final String address;
  final double? lat;
  final double? lng;
  final int? maxParticipants;
  final double? price;
  final DateTime? start; // ⬅️ date (nullable)
  final DateTime? end; // ⬅️ date (nullable)
  final File? image;
  final String? imageUrl;
  // ===== lookups =====
  final List<ItemType> types;
  final Currency? currency;
  // ===== ui =====
  final bool loading;
  final String? error;
  final String? success;
  // ===== stripe =====
  final bool stripeConnected;

  const CreateItemState({
    this.businessId,
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
    this.types = const [],
    this.currency,
    this.loading = false,
    this.error,
    this.success,
    this.stripeConnected = false,
  });

  // Simple readiness check
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

  // ======= SENTINEL PATTERN (lets us set nulls explicitly) =======
  static const Object _noChange = Object();

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
    Object? start = _noChange, // ⬅️ Object? + sentinel
    Object? end = _noChange, // ⬅️ Object? + sentinel
    File? image,
    Object? imageUrl = _noChange, // optional: allow clearing imageUrl too
    List<ItemType>? types,
    Currency? currency,
    bool? loading,
    Object? error = _noChange, // optional: allow clearing error
    Object? success = _noChange, // optional: allow clearing success
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

      // if param is _noChange → keep; else cast Even if null → set null
      start: identical(start, _noChange) ? this.start : (start as DateTime?),
      end: identical(end, _noChange) ? this.end : (end as DateTime?),

      image: image ?? this.image,
      imageUrl: identical(imageUrl, _noChange)
          ? this.imageUrl
          : (imageUrl as String?),
      types: types ?? this.types,
      currency: currency ?? this.currency,
      loading: loading ?? this.loading,
      error: identical(error, _noChange) ? this.error : (error as String?),
      success: identical(success, _noChange)
          ? this.success
          : (success as String?),
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
    types,
    currency,
    loading,
    error,
    success,
    stripeConnected,
  ];
}
