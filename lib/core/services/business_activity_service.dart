// ===== Flutter 3.35.x =====
// services/business_activity_service.dart
// Business items (activities): list by business, details, create (with image),
// update (with optional imageRemoved), delete, and get activity types.
//
// We use our shared ApiFetch (Dio-based) so it feels like Axios.
//
// NOTE: Our global Dio baseUrl already ends with "/api",
// so below we use "/items" and "/item-types" (NOT "/api/items").

import 'package:dio/dio.dart'; // FormData/Multipart
import 'package:hobby_sphere/core/network/api_fetch.dart'; // axios-like helper
import 'package:hobby_sphere/core/network/api_methods.dart'; // HTTP method names

class BusinessActivityService {
  // create one ApiFetch instance to reuse the same Dio client
  final _fetch = ApiFetch(); // shared helper

  // base paths (final URL => <server>/api/items ...)
  static const _itemsBase = '/items'; // items base
  static const _typesBase = '/item-types'; // item-types base

  // small helper: extract file name from a path like ".../foo.jpg"
  String _fileName(String path) => path.split('/').last; // last segment

  // small helper: naive mime from extension (png => image/png else image/jpeg)
  String _mimeByExt(String fileName) {
    final lower = fileName.toLowerCase(); // lower-case
    return lower.endsWith('.png') ? 'image/png' : 'image/jpeg'; // basic guess
  }

  // ------------------------------------------------------------
  // GET /api/items/business/{businessId}
  // same as: getActivitiesByBusiness(businessId, token)
  Future<List<dynamic>> getActivitiesByBusiness({
    required int businessId, // business id
    required String token, // JWT token
  }) async {
    final res = await _fetch.fetch(
      // send request
      HttpMethod.get, // GET
      '$_itemsBase/business/$businessId', // path
      headers: {'Authorization': 'Bearer $token'}, // auth header
    );
    final data = res.data; // response JSON
    if (data is! List) throw Exception('Invalid list response'); // guard
    return data; // list of items
  }

  // ------------------------------------------------------------
  // GET /api/items/{id}
  // same as: getActivityByIdForBusiness(id, token)
  Future<Map<String, dynamic>> getActivityByIdForBusiness({
    required int id, // item id
    required String token, // JWT token
  }) async {
    final res = await _fetch.fetch(
      // send request
      HttpMethod.get, // GET
      '$_itemsBase/$id', // path
      headers: {'Authorization': 'Bearer $token'}, // auth header
    );
    final data = res.data; // response JSON
    if (data is! Map) throw Exception('Invalid item response'); // guard
    return Map<String, dynamic>.from(data); // typed map
  }

  // ------------------------------------------------------------
  // POST /api/items/create  (multipart/form-data)
  // same as: createActivity(activity, businessId, token)
  //
  // activity map should contain keys (same as RN):
  // activityName, activityType, description, location,
  // latitude, longitude, maxParticipants, price,
  // startDatetime, endDatetime, status, imageUri (optional).
  Future<Map<String, dynamic>> createActivity({
    required Map<String, dynamic> activity, // form fields
    required int businessId, // business id
    required String token, // JWT token
  }) async {
    // read fields from the map (simple, same names as RN object)
    final String activityName = '${activity['activityName'] ?? ''}'; // name
    final dynamic activityType = activity['activityType']; // type id
    final String description = '${activity['description'] ?? ''}'; // desc
    final String location = '${activity['location'] ?? ''}'; // address
    final String? imageUri = activity['imageUri'] as String?; // image path
    final double? latitude = (activity['latitude'] == null)
        ? null
        : double.tryParse('${activity['latitude']}'); // to double
    final double? longitude = (activity['longitude'] == null)
        ? null
        : double.tryParse('${activity['longitude']}'); // to double
    final int maxParticipants = int.parse(
      '${activity['maxParticipants']}',
    ); // to int
    final num price = num.parse('${activity['price']}'); // accept int/double
    // accept either DateTime or String; always convert to ISO 8601
    String _toIso(dynamic v) => (v is DateTime)
        ? v.toIso8601String()
        : DateTime.parse('$v').toIso8601String(); // parse->ISO
    final String startIso = _toIso(activity['startDatetime']); // start ISO
    final String endIso = _toIso(activity['endDatetime']); // end ISO
    final String status = '${activity['status'] ?? ''}'; // status str

    // build multipart form data (field names mapped like your RN code)
    final form = FormData(); // init form
    form.fields
      ..add(MapEntry('itemName', activityName)) // itemName
      ..add(MapEntry('itemTypeId', '$activityType')) // itemTypeId
      ..add(MapEntry('description', description)) // description
      ..add(MapEntry('location', location)) // location
      ..add(MapEntry('latitude', latitude?.toString() ?? '')) // latitude
      ..add(MapEntry('longitude', longitude?.toString() ?? '')) // longitude
      ..add(MapEntry('maxParticipants', '$maxParticipants')) // maxParticipants
      ..add(MapEntry('price', '$price')) // price
      ..add(MapEntry('startDatetime', startIso)) // startDatetime
      ..add(MapEntry('endDatetime', endIso)) // endDatetime
      ..add(MapEntry('status', status)) // status
      ..add(MapEntry('businessId', '$businessId')); // businessId

    // if we have an imageUri, attach it as "image" part
    if (imageUri != null && imageUri.isNotEmpty) {
      // has file?
      final name = _fileName(imageUri); // file name
      final mime = _mimeByExt(name); // guess mime
      form.files.add(
        MapEntry(
          'image', // field name
          await MultipartFile.fromFile(
            // load file
            imageUri, // local path
            filename: name, // name
            // contentType is optional; Dio can infer from extension; omitted for simplicity
          ),
        ),
      );
    }

    // send request with multipart header + bearer token
    final res = await _fetch.fetch(
      HttpMethod.post, // POST
      '$_itemsBase/create', // path
      data: form, // multipart body
      headers: {
        'Authorization': 'Bearer $token', // auth
        'Content-Type': 'multipart/form-data', // multipart
      },
    );

    // validate object response
    final data = res.data; // JSON
    if (data is! Map) throw Exception('Invalid create response'); // guard
    return Map<String, dynamic>.from(data); // created item
  }

  // ------------------------------------------------------------
  // PUT /api/items/{id}/update-with-image  (multipart/form-data)
  // same as: updateActivity(id, activity, token)
  //
  // activity map should contain:
  // activityName, activityType, description, location,
  // latitude, longitude, maxParticipants, price,
  // startDatetime, endDatetime, status, businessId, imageRemoved (bool),
  // imageUri (optional, ignored if imageRemoved == true).
  Future<Map<String, dynamic>> updateActivity({
    required int id, // item id
    required Map<String, dynamic> activity, // fields
    required String token, // JWT token
  }) async {
    // pull fields from map
    final String name = '${activity['activityName'] ?? ''}'; // name
    final dynamic typeId = activity['activityType']; // type id
    final String desc = '${activity['description'] ?? ''}'; // desc
    final String loc = '${activity['location'] ?? ''}'; // address
    final double lat = double.parse('${activity['latitude']}'); // latitude
    final double lon = double.parse('${activity['longitude']}'); // longitude
    final int max = int.parse(
      '${activity['maxParticipants']}',
    ); // max participants
    final num price = num.parse('${activity['price']}'); // price
    String _toIso(dynamic v) => (v is DateTime)
        ? v.toIso8601String()
        : DateTime.parse('$v').toIso8601String(); // parse->ISO
    final String startIso = _toIso(activity['startDatetime']); // start ISO
    final String endIso = _toIso(activity['endDatetime']); // end ISO
    final String status = '${activity['status'] ?? ''}'; // status
    final int businessId = int.parse(
      '${activity['businessId']}',
    ); // business id
    final bool imageRemoved = activity['imageRemoved'] == true; // removed flag
    final String? imageUri = activity['imageUri'] as String?; // optional path

    // build multipart form
    final form = FormData(); // init
    form.fields
      ..add(MapEntry('itemName', name)) // itemName
      ..add(MapEntry('itemTypeId', '$typeId')) // itemTypeId
      ..add(MapEntry('description', desc)) // description
      ..add(MapEntry('location', loc)) // location
      ..add(MapEntry('latitude', '$lat')) // latitude
      ..add(MapEntry('longitude', '$lon')) // longitude
      ..add(MapEntry('maxParticipants', '$max')) // max
      ..add(MapEntry('price', '$price')) // price
      ..add(MapEntry('startDatetime', startIso)) // start
      ..add(MapEntry('endDatetime', endIso)) // end
      ..add(MapEntry('status', status)) // status
      ..add(MapEntry('businessId', '$businessId')) // businessId
      ..add(
        MapEntry('imageRemoved', imageRemoved ? 'true' : 'false'),
      ); // required

    // attach file only if NOT removed and imageUri present
    if (!imageRemoved && imageUri != null && imageUri.isNotEmpty) {
      final name = _fileName(imageUri); // file name
      final mime = _mimeByExt(name); // guess mime
      form.files.add(
        MapEntry(
          'image', // field name
          await MultipartFile.fromFile(
            // load file
            imageUri, // path
            filename: name, // name
            // contentType optional
          ),
        ),
      );
    }

    // send request with multipart + auth
    final res = await _fetch.fetch(
      HttpMethod.put, // PUT
      '$_itemsBase/$id/update-with-image', // path
      data: form, // multipart
      headers: {
        'Authorization': 'Bearer $token', // auth
        'Content-Type': 'multipart/form-data', // multipart
      },
    );

    // ensure object response
    final data = res.data; // JSON
    if (data is! Map) throw Exception('Invalid update response'); // guard
    return Map<String, dynamic>.from(data); // updated item
  }

  // ------------------------------------------------------------
  // DELETE /api/items/{id}
  // same as: deleteActivity(id, token)
  Future<Map<String, dynamic>> deleteActivity({
    required int id, // item id
    required String token, // JWT token
  }) async {
    final res = await _fetch.fetch(
      // send request
      HttpMethod.delete, // DELETE
      '$_itemsBase/$id', // path
      headers: {'Authorization': 'Bearer $token'}, // auth
    );
    final data = res.data; // JSON
    if (data is! Map) throw Exception('Invalid delete response'); // guard
    return Map<String, dynamic>.from(data); // backend payload
  }

  // ------------------------------------------------------------
  // GET /api/item-types
  // same as: getActivityTypes(token)
  Future<List<dynamic>> getActivityTypes({
    required String token, // JWT token
  }) async {
    final res = await _fetch.fetch(
      // send request
      HttpMethod.get, // GET
      _typesBase, // "/item-types"
      headers: {'Authorization': 'Bearer $token'}, // auth
    );
    final data = res.data; // JSON
    if (data is! List)
      throw Exception('Invalid activity types response'); // guard
    return data; // list
  }
}
