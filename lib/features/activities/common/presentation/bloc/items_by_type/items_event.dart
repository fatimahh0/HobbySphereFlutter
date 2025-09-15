// Event – load items for a given type id
abstract class ItemsByTypeEvent {} // base

class ItemsByTypeLoadRequested extends ItemsByTypeEvent {
  // load
  final int typeId; // filter id
  ItemsByTypeLoadRequested(this.typeId); // ctor
}
