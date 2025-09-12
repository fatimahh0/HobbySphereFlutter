// ===== lib/features/activities/Business/createActivity/presentation/bloc/create_item_state.dart =====
// Flutter 3.35.x
import 'dart:io'; // File
import 'package:equatable/equatable.dart'; // For easy ==

import 'package:hobby_sphere/features/activities/common/domain/entities/item_type.dart'; // Types entity
import 'package:hobby_sphere/features/activities/common/domain/entities/currency.dart'; // Currency entity

class CreateItemState extends Equatable {
  final bool loading; // Busy flag
  final String? error; // Error message
  final String? success; // Success message

  final String name; // Name
  final int? itemTypeId; // Type id
  final String description; // Description

  final String address; // Address
  final double? lat; // Latitude
  final double? lng; // Longitude

  final int? maxParticipants; // Capacity
  final double? price; // Price

  final DateTime? start; // Start date-time
  final DateTime? end; // End date-time

  final File? image; // Picked file
  final String? imageUrl; // Retained image URL

  final List<ItemType> types; // Types dropdown
  final Currency? currency; // Currency

  final int? businessId; // Business id
  final String status; // Status (default ACTIVE)

  const CreateItemState({
    this.loading = false, // Default not busy
    this.error, // No error by default
    this.success, // No success by default
    this.name = '', // Empty name
    this.itemTypeId, // No type yet
    this.description = '', // Empty description
    this.address = '', // Empty address
    this.lat, // No lat
    this.lng, // No lng
    this.maxParticipants, // No capacity
    this.price, // No price
    this.start, // No start
    this.end, // No end
    this.image, // No file
    this.imageUrl, // No URL
    this.types = const [], // Empty types
    this.currency, // No currency
    this.businessId, // Injected later
    this.status = 'ACTIVE', // Default ACTIVE
  });

  bool get ready => // Form validation
      name.trim().isNotEmpty && // Has name
      itemTypeId != null && // Has type
      description.trim().isNotEmpty && // Has description
      address.trim().isNotEmpty && // Has address
      lat != null && // Has lat
      lng != null && // Has lng
      (maxParticipants ?? 0) > 0 && // Has capacity > 0
      (price ?? -1) >= 0 && // Has price >= 0
      start != null && // Has start
      end != null && // Has end
      (businessId ?? 0) > 0 && // ✅ must be > 0 (not just non-null)
      (image != null || imageUrl?.isNotEmpty == true);
  CreateItemState copyWith({
    bool? loading, // Optional new loading
    String? error, // Optional new error (null clears)
    String? success, // Optional new success (null clears)
    String? name, // Optional new name
    int? itemTypeId, // Optional new type
    String? description, // Optional new description
    String? address, // Optional new address
    double? lat, // Optional new lat
    double? lng, // Optional new lng
    int? maxParticipants, // Optional new capacity
    double? price, // Optional new price
    DateTime? start, // Optional new start
    DateTime? end, // Optional new end
    File? image, // Optional new file
    List<ItemType>? types, // Optional new types
    Currency? currency, // Optional new currency
    int? businessId, // Optional new business id
    String? status, // Optional new status
    String? imageUrl, // Optional new URL
  }) {
    return CreateItemState(
      loading: loading ?? this.loading, // Keep or set loading
      error: error, // Replace error (even null)
      success: success, // Replace success (even null)
      name: name ?? this.name, // Keep or set name
      itemTypeId: itemTypeId ?? this.itemTypeId, // Keep or set type
      description: description ?? this.description, // Keep or set description
      address: address ?? this.address, // Keep or set address
      lat: lat ?? this.lat, // Keep or set lat
      lng: lng ?? this.lng, // Keep or set lng
      maxParticipants:
          maxParticipants ?? this.maxParticipants, // Keep or set capacity
      price: price ?? this.price, // Keep or set price
      start: start ?? this.start, // Keep or set start
      end: end ?? this.end, // Keep or set end
      image: image ?? this.image, // Keep or set file
      imageUrl: imageUrl ?? this.imageUrl, // Keep or set URL
      types: types ?? this.types, // Keep or set types
      currency: currency ?? this.currency, // Keep or set currency
      businessId: businessId ?? this.businessId, // Keep or set business id
      status: status ?? this.status, // Keep or set status
    );
  }

  @override
  List<Object?> get props => [
    // Equatable props
    loading, error, success, // Status messages
    name, itemTypeId, description, // Basic fields
    address, lat, lng, // Location
    maxParticipants, price, // Numbers
    start, end, // Dates
    image?.path, imageUrl, // Image sources
    types, currency?.code, // Dropdowns
    businessId, status, // Meta
  ];
}
