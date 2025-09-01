import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:hobby_sphere/features/activities/common/domain/entities/item_type.dart';
import 'package:hobby_sphere/features/activities/common/domain/entities/currency.dart';

class CreateItemState extends Equatable {
  final bool loading;
  final String? error;
  final String? success;

  final String name;
  final int? itemTypeId;
  final String description;

  final String address;
  final double? lat;
  final double? lng;

  final int? maxParticipants;
  final double? price;

  final DateTime? start;
  final DateTime? end;

  final File? image;

  final List<ItemType> types;
  final Currency? currency;

  final int? businessId; // injected from page
  final String status; // default "ACTIVE"

  const CreateItemState({
    this.loading = false,
    this.error,
    this.success,
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
    this.types = const [],
    this.currency,
    this.businessId,
    this.status = 'ACTIVE',
  });

  bool get ready =>
      name.trim().isNotEmpty &&
      itemTypeId != null &&
      description.trim().isNotEmpty &&
      address.trim().isNotEmpty &&
      lat != null &&
      lng != null &&
      (maxParticipants ?? 0) > 0 &&
      (price ?? -1) >= 0 &&
      start != null &&
      end != null &&
      businessId != null;

  CreateItemState copyWith({
    bool? loading,
    String? error,
    String? success,
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
    List<ItemType>? types,
    Currency? currency,
    int? businessId,
    String? status,
  }) {
    return CreateItemState(
      loading: loading ?? this.loading,
      error: error,
      success: success,
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
      types: types ?? this.types,
      currency: currency ?? this.currency,
      businessId: businessId ?? this.businessId,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
    loading,
    error,
    success,
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
    image?.path,
    types,
    currency?.code,
    businessId,
    status,
  ];
}
