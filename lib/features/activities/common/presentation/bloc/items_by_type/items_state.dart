// States – items by type
import '../../../domain/entities/item_details.dart'; // entity

abstract class ItemsByTypeState {
  const ItemsByTypeState();
} // base

class ItemsByTypeInitial extends ItemsByTypeState {
  const ItemsByTypeInitial();
} // idle

class ItemsByTypeLoading extends ItemsByTypeState {
  const ItemsByTypeLoading();
} // spinner

class ItemsByTypeLoaded extends ItemsByTypeState {
  // success
  final List<ItemDetailsEntity> items; // items
  const ItemsByTypeLoaded(this.items); // ctor
}

class ItemsByTypeError extends ItemsByTypeState {
  // error
  final String message; // text
  const ItemsByTypeError(this.message); // ctor
}
