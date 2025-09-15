// States for types
import '../../../domain/entities/item_type.dart'; // entity

abstract class TypesState {
  const TypesState();
} // base

class TypesInitial extends TypesState {
  const TypesInitial();
} // idle

class TypesLoading extends TypesState {
  const TypesLoading();
} // spinner

class TypesLoaded extends TypesState {
  // success
  final List<ItemType> types; // list
  const TypesLoaded(this.types); // ctor
}

class TypesError extends TypesState {
  // error
  final String message; // text
  const TypesError(this.message); // ctor
}
