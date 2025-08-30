// ===== Flutter 3.35.x =====
// Service — multipart POST /api/items/create + GET /api/item-types
// Uses your ApiFetch.fetch() for all calls.

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;

import 'package:hobby_sphere/core/network/api_fetch.dart' as net;
import 'package:hobby_sphere/core/network/api_methods.dart'; // HttpMethod

class BusinessCreateActivityService {
  final String _itemsBase = '/api/items';
  final String _typesBase = '/api/item-types';

  final net.ApiFetch _fetch = net.ApiFetch();

  Future<Map<String, dynamic>> createActivity({
    required Map<String, dynamic> activity,
    required int businessId,
    required String token,
  }) async {
    final form = FormData();

    // Scalars → add if not null
    final fields = <String, dynamic>{
      'businessId': businessId, // remove if your backend uses URL param instead
      'activityName': activity['activityName'],
      'activityType': activity['activityType'],
      'description': activity['description'],
      'location': activity['location'],
      'status': activity['status'],
      'latitude': activity['latitude'],
      'longitude': activity['longitude'],
      'maxParticipants': activity['maxParticipants'],
      'price': activity['price'],
      'startDatetime': activity['startDatetime'],
      'endDatetime': activity['endDatetime'],
    };
    fields.forEach((k, v) {
      if (v != null) form.fields.add(MapEntry(k, v.toString()));
    });

    // Optional image
    final String? imageUri = activity['imageUri'] as String?;
    if (imageUri != null && imageUri.trim().isNotEmpty) {
      form.files.add(
        MapEntry(
          'image', // change to 'banner' if your backend expects that
          await MultipartFile.fromFile(
            imageUri,
            filename: p.basename(imageUri),
            contentType: MediaType.parse(_mimeByExt(imageUri)),
          ),
        ),
      );
    }

    // Use ApiFetch.fetch (POST)
    final res = await _fetch.fetch(
      HttpMethod.post,
      '$_itemsBase/create',
      data: form,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'multipart/form-data',
      },
    );

    final data = res.data;
    if (data is! Map) throw Exception('Invalid create response');
    return Map<String, dynamic>.from(data);
  }

  // GET /api/item-types — dropdown source
  Future<List<dynamic>> getActivityTypes({required String token}) async {
    final res = await _fetch.fetch(
      HttpMethod.get,
      _typesBase,
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = res.data;
    if (data is! List) throw Exception('Invalid activity types response');
    return data;
  }

  String _mimeByExt(String path) {
    final ext = p.extension(path).toLowerCase();
    if (ext == '.png') return 'image/png';
    if (ext == '.webp') return 'image/webp';
    if (ext == '.heic' || ext == '.heif') return 'image/heic';
    return 'image/jpeg';
  }
}
