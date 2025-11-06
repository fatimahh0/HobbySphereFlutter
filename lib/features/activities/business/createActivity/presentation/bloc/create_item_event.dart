// Flutter 3.35.x — simple and clean
// Every line has a short comment.

// ===== Imports =====
import 'dart:io'; // for File
import 'package:equatable/equatable.dart'; // value equality

// ===== Base event =====
abstract class CreateItemEvent extends Equatable {
  @override
  List<Object?> get props => []; // default equality list
}

// Fire once when screen opens (load dropdowns + currency + stripe)
class CreateItemBootstrap extends CreateItemEvent {}

// Fire after returning from Profile or when user taps refresh in banner
class CreateItemRecheckStripe extends CreateItemEvent {}

// Name changed
class CreateItemNameChanged extends CreateItemEvent {
  final String name; // new value
  CreateItemNameChanged(this.name); // ctor
  @override
  List<Object?> get props => [name]; // eq by name
}

// Keep old image URL (when editing)
class CreateItemImageUrlRetained extends CreateItemEvent {
  final String imageUrl; // url value
  CreateItemImageUrlRetained(this.imageUrl); // ctor
  @override
  List<Object?> get props => [imageUrl]; // eq by url
}

// Type changed
class CreateItemTypeChanged extends CreateItemEvent {
  final int? typeId; // selected id
  CreateItemTypeChanged(this.typeId); // ctor
  @override
  List<Object?> get props => [typeId]; // eq by id
}

// Description changed
class CreateItemDescriptionChanged extends CreateItemEvent {
  final String description; // new text
  CreateItemDescriptionChanged(this.description); // ctor
  @override
  List<Object?> get props => [description]; // eq by text
}

// Location picked from map
class CreateItemLocationPicked extends CreateItemEvent {
  final String address; // address text
  final double lat; // latitude
  final double lng; // longitude
  CreateItemLocationPicked(this.address, this.lat, this.lng); // ctor
  @override
  List<Object?> get props => [address, lat, lng]; // eq
}

// Max participants changed
class CreateItemMaxChanged extends CreateItemEvent {
  final int? max; // new value
  CreateItemMaxChanged(this.max); // ctor
  @override
  List<Object?> get props => [max]; // eq
}

// Price changed
class CreateItemPriceChanged extends CreateItemEvent {
  final double? price; // new value
  CreateItemPriceChanged(this.price); // ctor
  @override
  List<Object?> get props => [price]; // eq
}

// Image picked (or cleared)
class CreateItemImagePicked extends CreateItemEvent {
  final File? image; // file or null
  CreateItemImagePicked(this.image); // ctor
  @override
  List<Object?> get props => [image?.path]; // eq by path
}

// Start changed
class CreateItemStartChanged extends CreateItemEvent {
  final DateTime? dt; // new start
  CreateItemStartChanged(this.dt); // ctor
}

// End changed
class CreateItemEndChanged extends CreateItemEvent {
  final DateTime? dt; // new end
  CreateItemEndChanged(this.dt); // ctor
}

// Submit pressed
class CreateItemSubmitPressed extends CreateItemEvent {}
