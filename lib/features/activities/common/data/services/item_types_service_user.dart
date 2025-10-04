// ===== Flutter 3.35.x =====
// Service: Item Types (Activity Types)
// This converts your RN functions to Flutter using our ApiFetch helper.

import 'package:hobby_sphere/core/network/api_fetch.dart'; // HTTP helper (Dio)
import 'package:hobby_sphere/core/network/api_methods.dart'; // method names

class ItemTypesService {
  // create one fetch helper (reuses the global Dio client)
  final _fetch = ApiFetch(); // shared instance

  // base path for this service (global baseUrl already contains "/api")
  static const _base = '/item-types'; // final URL => <server>/api/item-type

  // ------------------------------------------------------------
  // GET /api/item-type/guest
  // same as: getAllActivityTypes() in RN
  Future<List<dynamic>> getAllActivityTypes() async {
    // call GET /item-type/guest
    final res = await _fetch.fetch(
      HttpMethod.get, // HTTP method
      '$_base/guest', // endpoint path
    );

    // read the payload
    final data = res.data; // dynamic type from Dio

    // validate that response is a JSON array
    if (data is! List) {
      throw Exception('Invalid activity types response'); // same error text
    }

    // return the list as-is
    return data; // List<dynamic>
  }

  // ------------------------------------------------------------
  // GET /api/item-type/guest
  // same as: getActivityTypesCategories() in RN (same endpoint)
  Future<List<dynamic>> getActivityTypesCategories() async {
    // call GET /item-type/guest (same endpoint used in your RN code)
    final res = await _fetch.fetch(
      HttpMethod.get, // HTTP method
      '$_base/guest', // endpoint path
    );

    // read the payload
    final data = res.data; // dynamic type from Dio

    // validate that response is a JSON array
    if (data is! List) {
      throw Exception('Invalid activity types response'); // same error text
    }

    // return the list as-is
    return data; // List<dynamic>
  }
}
