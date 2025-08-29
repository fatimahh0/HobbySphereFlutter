// ===== Flutter 3.35.x =====
// Business items (activities): list, details, create (with image),
// update (with optional imageRemoved), delete, and item types.
// Uses a shared ApiFetch (Dio-based) so it feels like Axios.

import 'package:dio/dio.dart'; // FormData / MultipartFile
import 'package:path/path.dart' as p; // safe file name (Windows/macOS/Linux)
import 'package:http_parser/http_parser.dart'; // MediaType for multipart
import 'package:hobby_sphere/core/network/api_fetch.dart'; // axios-like fetch()
import 'package:hobby_sphere/core/network/api_methods.dart'; // HttpMethod enum

class BusinessActivityService {
  // Reuse one ApiFetch (shared Dio instance under the hood)
  final _fetch = ApiFetch(); // shared HTTP helper

  // Base paths (global Dio baseUrl already ends with "/api")
  static const _itemsBase = '/items'; // -> <server>/api/items
  static const _typesBase = '/item-types'; // -> <server>/api/item-types

  // ---------- helpers --------------------------------------------------------

  // Get file name from any OS path (uses 'path' package)
  String _fileName(String path) =>
      p.basename(path); // e.g. ".../foo.jpg" -> "foo.jpg"

  // Very small mime guess by extension (good enough for PNG/JPEG)
  String _mimeByExt(String name) => name.toLowerCase().endsWith('.png')
      ? 'image/png'
      : 'image/jpeg'; // default jpeg

  // Add a string field to FormData only if value is not null/empty
  void _addField(FormData form, String key, String? value) {
    if (value != null && value.isNotEmpty)
      form.fields.add(MapEntry(key, value)); // safe add
  }

  // Convert dynamic date (String or DateTime) to ISO 8601 string
  String _toIso(dynamic v) {
    // If already DateTime → to ISO
    if (v is DateTime) return v.toIso8601String(); // convert
    // If string → try parse then to ISO
    if (v is String) {
      final dt = DateTime.tryParse(v); // safe parse
      if (dt != null) return dt.toIso8601String(); // convert
    }
    // Anything else → invalid input
    throw Exception('Invalid date value'); // guard
  }

  // ---------- endpoints ------------------------------------------------------

  // GET /api/items/business/{businessId}
  Future<List<dynamic>> getActivitiesByBusiness({
    required int businessId, // business id
    required String token, // bearer token
  }) async {
    // Send GET with Authorization header
    final res = await _fetch.fetch(
      HttpMethod.get, // method
      '$_itemsBase/business/$businessId', // path
      headers: {'Authorization': 'Bearer $token'}, // auth
    );
    // Validate payload type
    final data = res.data; // response json
    if (data is! List) throw Exception('Invalid list response'); // guard
    return data; // list
  }

  // GET /api/items/{id}
  Future<Map<String, dynamic>> getActivityByIdForBusiness({
    required int id, // item id
    required String token, // bearer token
  }) async {
    // Send GET
    final res = await _fetch.fetch(
      HttpMethod.get, // method
      '$_itemsBase/$id', // path
      headers: {'Authorization': 'Bearer $token'}, // auth
    );
    // Validate map payload
    final data = res.data; // response json
    if (data is! Map) throw Exception('Invalid item response'); // guard
    return Map<String, dynamic>.from(data); // typed map
  }

  // ALIAS: keep UI compatibility (if your UI calls getBusinessActivityById)
  Future<Map<String, dynamic>> getBusinessActivityById(String token, int id) =>
      getActivityByIdForBusiness(id: id, token: token); // simple forward

  // POST /api/items/create  (multipart/form-data)
  Future<Map<String, dynamic>> createActivity({
    required Map<String, dynamic> activity, // input fields
    required int businessId, // business id
    required String token, // bearer token
  }) async {
    // Read basic fields from the map (loose typing to match RN)
    final String activityName = '${activity['activityName'] ?? ''}'; // name
    final dynamic activityType = activity['activityType']; // type id
    final String description = '${activity['description'] ?? ''}'; // desc
    final String location = '${activity['location'] ?? ''}'; // address
    final String? imageUri =
        activity['imageUri'] as String?; // local image path
    final String status = '${activity['status'] ?? ''}'; // status string

    // Optional coords (nullable)
    final String? latStr = activity['latitude']
        ?.toString(); // latitude as string
    final String? lonStr = activity['longitude']
        ?.toString(); // longitude as string

    // Required numbers
    final int maxParticipants = int.parse(
      '${activity['maxParticipants']}',
    ); // max
    final num price = num.parse('${activity['price']}'); // price

    // Dates (accept DateTime or String)
    final String startIso = _toIso(activity['startDatetime']); // start ISO
    final String endIso = _toIso(activity['endDatetime']); // end ISO

    // Build multipart form
    final form = FormData(); // new form
    _addField(form, 'itemName', activityName); // itemName
    _addField(form, 'itemTypeId', '$activityType'); // itemTypeId
    _addField(form, 'description', description); // description
    _addField(form, 'location', location); // location
    _addField(form, 'latitude', latStr); // latitude (optional)
    _addField(form, 'longitude', lonStr); // longitude (optional)
    _addField(form, 'maxParticipants', '$maxParticipants'); // maxParticipants
    _addField(form, 'price', '$price'); // price
    _addField(form, 'startDatetime', startIso); // startDatetime
    _addField(form, 'endDatetime', endIso); // endDatetime
    _addField(form, 'status', status); // status
    _addField(form, 'businessId', '$businessId'); // businessId

    // Attach image if present
    if (imageUri != null && imageUri.isNotEmpty) {
      final name = _fileName(imageUri); // file name
      final mime = _mimeByExt(name); // mime guess (e.g., image/jpeg)
      form.files.add(
        MapEntry(
          'image', // field name on backend
          await MultipartFile.fromFile(
            imageUri, // local path
            filename: name, // file name
            contentType: MediaType.parse(mime), // proper content-type
          ),
        ),
      );
    }

    // Send POST as multipart with bearer token
    final res = await _fetch.fetch(
      HttpMethod.post, // method
      '$_itemsBase/create', // path
      data: form, // multipart body
      headers: {
        'Authorization': 'Bearer $token', // auth
        'Content-Type': 'multipart/form-data', // multipart
      },
    );

    // Validate map response
    final data = res.data; // json
    if (data is! Map) throw Exception('Invalid create response'); // guard
    return Map<String, dynamic>.from(data); // created item
  }

  // PUT /api/items/{id}/update-with-image  (multipart/form-data)
  Future<Map<String, dynamic>> updateActivity({
    required int id, // item id
    required Map<String, dynamic> activity, // input fields
    required String token, // bearer token
  }) async {
    // Read fields
    final String name = '${activity['activityName'] ?? ''}'; // name
    final dynamic typeId = activity['activityType']; // type id
    final String desc = '${activity['description'] ?? ''}'; // desc
    final String loc = '${activity['location'] ?? ''}'; // address

    // Latitude/Longitude can be null in update → handle safely
    final String? latStr = activity['latitude']?.toString(); // latitude
    final String? lonStr = activity['longitude']?.toString(); // longitude

    final int max = int.parse(
      '${activity['maxParticipants']}',
    ); // max participants
    final num price = num.parse('${activity['price']}'); // price
    final String startIso = _toIso(activity['startDatetime']); // start ISO
    final String endIso = _toIso(activity['endDatetime']); // end ISO
    final String status = '${activity['status'] ?? ''}'; // status
    final int businessId = int.parse(
      '${activity['businessId']}',
    ); // business id
    final bool imageRemoved = activity['imageRemoved'] == true; // remove flag
    final String? imageUri = activity['imageUri'] as String?; // optional path

    // Build multipart form
    final form = FormData(); // new form
    _addField(form, 'itemName', name); // itemName
    _addField(form, 'itemTypeId', '$typeId'); // itemTypeId
    _addField(form, 'description', desc); // description
    _addField(form, 'location', loc); // location
    _addField(form, 'latitude', latStr); // latitude (optional)
    _addField(form, 'longitude', lonStr); // longitude (optional)
    _addField(form, 'maxParticipants', '$max'); // max
    _addField(form, 'price', '$price'); // price
    _addField(form, 'startDatetime', startIso); // start
    _addField(form, 'endDatetime', endIso); // end
    _addField(form, 'status', status); // status
    _addField(form, 'businessId', '$businessId'); // businessId
    _addField(
      form,
      'imageRemoved',
      imageRemoved ? 'true' : 'false',
    ); // send as "true"/"false"

    // Attach file only when NOT removed and we have a path
    if (!imageRemoved && imageUri != null && imageUri.isNotEmpty) {
      final name = _fileName(imageUri); // file name
      final mime = _mimeByExt(name); // mime guess
      form.files.add(
        MapEntry(
          'image', // field name
          await MultipartFile.fromFile(
            imageUri, // path
            filename: name, // name
            contentType: MediaType.parse(mime), // content-type
          ),
        ),
      );
    }

    // Send PUT as multipart
    final res = await _fetch.fetch(
      HttpMethod.put, // method
      '$_itemsBase/$id/update-with-image', // path
      data: form, // multipart body
      headers: {
        'Authorization': 'Bearer $token', // auth
        'Content-Type': 'multipart/form-data', // multipart
      },
    );

    // Validate map response
    final data = res.data; // json
    if (data is! Map) throw Exception('Invalid update response'); // guard
    return Map<String, dynamic>.from(data); // updated item
  }

  // DELETE /api/items/{id}
  Future<Map<String, dynamic>> deleteActivity({
    required int id, // item id
    required String token, // bearer token
  }) async {
    // Send DELETE
    final res = await _fetch.fetch(
      HttpMethod.delete, // method
      '$_itemsBase/$id', // path
      headers: {'Authorization': 'Bearer $token'}, // auth
    );
    // Validate map payload
    final data = res.data; // json
    if (data is! Map) throw Exception('Invalid delete response'); // guard
    return Map<String, dynamic>.from(data); // payload (e.g. {success:true})
  }

  // ALIAS: keep UI compatibility (if your UI calls deleteBusinessActivity)
  Future<Map<String, dynamic>> deleteBusinessActivity(String token, int id) =>
      deleteActivity(id: id, token: token); // forward

  // GET /api/item-types
  Future<List<dynamic>> getActivityTypes({
    required String token, // bearer token
  }) async {
    // Send GET
    final res = await _fetch.fetch(
      HttpMethod.get, // method
      _typesBase, // "/item-types"
      headers: {'Authorization': 'Bearer $token'}, // auth
    );
    // Validate array payload
    final data = res.data; // json
    if (data is! List)
      throw Exception('Invalid activity types response'); // guard
    return data; // list of types
  }
}
