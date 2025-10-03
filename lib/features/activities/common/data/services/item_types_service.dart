// raw HTTP service (Dio via your ApiFetch wrapper)
import 'package:hobby_sphere/core/network/api_fetch.dart'
    as net; // alias as net
import 'package:hobby_sphere/core/network/api_methods.dart'; // HttpMethod enum

class ItemTypesService {
  // create one ApiFetch instance
  final net.ApiFetch _fetch = net.ApiFetch(); // HTTP client
  // base path (adjust if backend differs)
  static const String _typesPath = '/item-type'; // endpoint path

  // returns raw JSON list from API
  Future<List<Map<String, dynamic>>> getTypes(String token) async {
    // perform GET call with bearer header
    final res = await _fetch.fetch(
      HttpMethod.get, // HTTP verb
      _typesPath, // endpoint
      headers: {'Authorization': 'Bearer $token'}, // auth
    );

    // take payload
    final data = res.data; // dynamic json

    // direct list: [ {...}, {...} ]
    if (data is List) {
      // cast each to map safely
      return data
          .cast<dynamic>() // dynamic list
          .map((e) => Map<String, dynamic>.from(e as Map)) // map item
          .toList(); // return list of maps
    }

    // wrapped list: { data: [ {...}, {...} ] }
    if (data is Map && data['data'] is List) {
      // unwrap 'data'
      final list = data['data'] as List; // inner list
      // cast each to map safely
      return list
          .cast<dynamic>() // dynamic list
          .map((e) => Map<String, dynamic>.from(e as Map)) // map item
          .toList(); // return list of maps
    }

    // fallback empty
    return <Map<String, dynamic>>[]; // nothing
  }
}
