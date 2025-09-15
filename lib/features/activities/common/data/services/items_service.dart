// HTTP service for items filtered by type (guest endpoint)
import 'package:hobby_sphere/core/network/api_fetch.dart'
    as net; // ApiFetch wrapper
import 'package:hobby_sphere/core/network/api_methods.dart'; // HttpMethod enum

class ItemsService {
  final net.ApiFetch _fetch = net.ApiFetch(); // http client

  Future<List<Map<String, dynamic>>> getByType(int typeId) async {
    final res = await _fetch.fetch(
      // perform GET
      HttpMethod.get, // verb
      '/items/by-type/$typeId', // endpoint
    );
    final data = res.data; // payload
    if (data is List) {
      // plain list
      return data
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(); // cast maps
    }
    return <Map<String, dynamic>>[]; // fallback empty
  }
}
