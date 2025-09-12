// ===== lib/features/activities/Business/createActivity/presentation/bloc/create_item_event.dart =====
// Flutter 3.35.x
import 'dart:io'; // File type
import 'package:equatable/equatable.dart'; // For easy ==

class CreateItemEvent extends Equatable {
  // Base event
  @override
  List<Object?> get props => []; // Default props
}

class CreateItemBootstrap
    extends CreateItemEvent {} // Load dropdowns + currency

class CreateItemNameChanged extends CreateItemEvent {
  // Update name
  final String name; // New value
  CreateItemNameChanged(this.name); // Ctor
  @override
  List<Object?> get props => [name]; // Equality
}

class CreateItemImageUrlRetained extends CreateItemEvent {
  // Keep old image URL
  final String imageUrl; // URL string
  CreateItemImageUrlRetained(this.imageUrl); // Ctor
  @override
  List<Object?> get props => [imageUrl]; // Equality
}

class CreateItemTypeChanged extends CreateItemEvent {
  // Update type
  final int? typeId; // New id
  CreateItemTypeChanged(this.typeId); // Ctor
  @override
  List<Object?> get props => [typeId]; // Equality
}

class CreateItemDescriptionChanged extends CreateItemEvent {
  // Update description
  final String description; // New text
  CreateItemDescriptionChanged(this.description); // Ctor
  @override
  List<Object?> get props => [description]; // Equality
}

class CreateItemLocationPicked extends CreateItemEvent {
  // Update location
  final String address; // Address text
  final double lat; // Latitude
  final double lng; // Longitude
  CreateItemLocationPicked(this.address, this.lat, this.lng); // Ctor
  @override
  List<Object?> get props => [address, lat, lng]; // Equality
}

class CreateItemMaxChanged extends CreateItemEvent {
  // Update capacity
  final int? max; // Value
  CreateItemMaxChanged(this.max); // Ctor
  @override
  List<Object?> get props => [max]; // Equality
}

class CreateItemPriceChanged extends CreateItemEvent {
  // Update price
  final double? price; // Value
  CreateItemPriceChanged(this.price); // Ctor
  @override
  List<Object?> get props => [price]; // Equality
}

class CreateItemImagePicked extends CreateItemEvent {
  // Picked file
  final File? image; // File or null
  CreateItemImagePicked(this.image); // Ctor
  @override
  List<Object?> get props => [image?.path]; // Use path for equality
}

class CreateItemStartChanged extends CreateItemEvent {
  // Update start datetime
  final DateTime? dt; // New value
  CreateItemStartChanged(this.dt); // Ctor
}

class CreateItemEndChanged extends CreateItemEvent {
  // Update end datetime
  final DateTime? dt; // New value
  CreateItemEndChanged(this.dt); // Ctor
}

class CreateItemSubmitPressed extends CreateItemEvent {} // Submit form
