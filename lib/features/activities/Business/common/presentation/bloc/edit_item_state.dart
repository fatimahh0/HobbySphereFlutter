import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:hobby_sphere/features/activities/common/domain/entities/currency.dart';
import 'package:hobby_sphere/features/activities/common/domain/entities/item_type.dart';

class EditItemState extends Equatable {
  final bool loading;
  final String? error;
  final String? success;

  final int? id;

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

  final File? image;     // new picked image
  final String? imageUrl; // existing network image
  final bool imageRemoved;

  final List<ItemType> types;
  final Currency? currency;

  final int businessId; // required
  final String status;

  const EditItemState({
    this.loading = false,
    this.error,
    this.success,
    this.id,
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
    this.imageRemoved = false,
    this.types = const [],
    this.currency,
    required this.businessId,
    this.status = 'ACTIVE',
  });

  bool get ready =>
      id != null &&
      name.trim().isNotEmpty &&
      itemTypeId != null &&
      description.trim().isNotEmpty &&
      address.trim().isNotEmpty &&
      lat != null &&
      lng != null &&
      (maxParticipants ?? 0) > 0 &&
      (price ?? -1) >= 0 &&
      start != null &&
      end != null;

  EditItemState copyWith({
    bool? loading,
    String? error,
    String? success,
    int? id,
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
    bool? imageRemoved,
    List<ItemType>? types,
    Currency? currency,
    int? businessId,
    String? status,
  }) {
    return EditItemState(
      loading: loading ?? this.loading,
      error: error,
      success: success,
      id: id ?? this.id,
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
      imageRemoved: imageRemoved ?? this.imageRemoved,
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
        id,
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
        imageUrl,
        imageRemoved,
        types,
        currency?.code,
        businessId,
        status,
      ];
}
