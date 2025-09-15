// Event – load types with token
abstract class TypesEvent {} // base event

class TypesLoadRequested extends TypesEvent {
  // load event
  final String token; // bearer token
  TypesLoadRequested(this.token); // ctor
}
