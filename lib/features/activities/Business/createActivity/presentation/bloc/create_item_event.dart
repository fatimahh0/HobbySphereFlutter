import 'dart:io';
import 'package:equatable/equatable.dart';

class CreateItemEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreateItemBootstrap extends CreateItemEvent {} // fetch types + currency

class CreateItemNameChanged extends CreateItemEvent {
  final String name;
  CreateItemNameChanged(this.name);
  @override
  List<Object?> get props => [name];
}

class CreateItemTypeChanged extends CreateItemEvent {
  final int? typeId;
  CreateItemTypeChanged(this.typeId);
  @override
  List<Object?> get props => [typeId];
}

class CreateItemDescriptionChanged extends CreateItemEvent {
  final String description;
  CreateItemDescriptionChanged(this.description);
  @override
  List<Object?> get props => [description];
}

class CreateItemLocationPicked extends CreateItemEvent {
  final String address;
  final double lat;
  final double lng;
  CreateItemLocationPicked(this.address, this.lat, this.lng);
  @override
  List<Object?> get props => [address, lat, lng];
}

class CreateItemMaxChanged extends CreateItemEvent {
  final int? max;
  CreateItemMaxChanged(this.max);
  @override
  List<Object?> get props => [max];
}

class CreateItemPriceChanged extends CreateItemEvent {
  final double? price;
  CreateItemPriceChanged(this.price);
  @override
  List<Object?> get props => [price];
}

class CreateItemImagePicked extends CreateItemEvent {
  final File? image;
  CreateItemImagePicked(this.image);
  @override
  List<Object?> get props => [image?.path];
}

class CreateItemStartChanged extends CreateItemEvent {
  final DateTime? dt; // was DateTime
  CreateItemStartChanged(this.dt);
}

class CreateItemEndChanged extends CreateItemEvent {
  final DateTime? dt; // was DateTime
  CreateItemEndChanged(this.dt);
}
class CreateItemSubmitPressed extends CreateItemEvent {}
