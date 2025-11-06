import 'dart:io';
import 'package:equatable/equatable.dart';

class EditItemEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class EditItemBootstrap extends EditItemEvent {
  final int itemId;
  EditItemBootstrap(this.itemId);
}

class EditItemNameChanged extends EditItemEvent {
  final String name;
  EditItemNameChanged(this.name);
  @override
  List<Object?> get props => [name];
}

class EditItemTypeChanged extends EditItemEvent {
  final int? typeId;
  EditItemTypeChanged(this.typeId);
  @override
  List<Object?> get props => [typeId];
}

class EditItemDescriptionChanged extends EditItemEvent {
  final String description;
  EditItemDescriptionChanged(this.description);
  @override
  List<Object?> get props => [description];
}

class EditItemLocationPicked extends EditItemEvent {
  final String address;
  final double lat;
  final double lng;
  EditItemLocationPicked(this.address, this.lat, this.lng);
  @override
  List<Object?> get props => [address, lat, lng];
}

class EditItemMaxChanged extends EditItemEvent {
  final int? max;
  EditItemMaxChanged(this.max);
  @override
  List<Object?> get props => [max];
}

class EditItemPriceChanged extends EditItemEvent {
  final double? price;
  EditItemPriceChanged(this.price);
  @override
  List<Object?> get props => [price];
}

class EditItemImagePicked extends EditItemEvent {
  final File? image;
  EditItemImagePicked(this.image);
  @override
  List<Object?> get props => [image?.path];
}

class EditItemImageRemovedToggled extends EditItemEvent {
  final bool removed;
  EditItemImageRemovedToggled(this.removed);
  @override
  List<Object?> get props => [removed];
}

class EditItemStartChanged extends EditItemEvent {
  final DateTime? dt;
  EditItemStartChanged(this.dt);
}

class EditItemEndChanged extends EditItemEvent {
  final DateTime? dt;
  EditItemEndChanged(this.dt);
}

class EditItemSubmitPressed extends EditItemEvent {}
