// Flutter 3.35.x — simple and clean
// Every line has a short comment.

import 'dart:io'; // File
import 'package:dio/dio.dart'; // FormData, MultipartFile
import 'package:http_parser/http_parser.dart'; // MediaType
import 'package:intl/intl.dart'; // DateFormat
import 'package:path/path.dart' as p; // basename

import 'package:hobby_sphere/core/network/api_fetch.dart'; // ApiFetch
import 'package:hobby_sphere/core/network/api_methods.dart'; // HttpMethod

class UpdatedItemService {
  final _fetch = ApiFetch(); // HTTP wrapper
  static const _base = '/items'; // maps to /api/items

  // Helper: ISO string without milliseconds (controller expects ISO.DATE_TIME)
  String _isoNoMillis(DateTime dt) =>
      DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(dt.toLocal());

  // ==== UPDATE (PUT /api/items/{id}) ====
  Future<Response> updateMultipart(
    String token, // bearer token
    int id, // item id
    Map<String, dynamic> body, // fields + optional 'image' File
  ) async {
    // Clone so we can safely modify
    final fields = Map<String, dynamic>.from(body); // copy map

    // Normalize dates if passed as DateTime
    if (fields['startDatetime'] is DateTime) {
      fields['startDatetime'] = _isoNoMillis(
        fields['startDatetime'] as DateTime,
      );
    }
    if (fields['endDatetime'] is DateTime) {
      fields['endDatetime'] = _isoNoMillis(fields['endDatetime'] as DateTime);
    }

    // Build multipart form
    final form = FormData(); // multipart/form-data

    // Add text fields (booleans as "true"/"false")
    fields.forEach((k, v) {
      if (v == null) return; // skip null
      if (v is File) return; // skip file (handled below)
      if (v is bool) {
        form.fields.add(MapEntry(k, v ? 'true' : 'false')); // "true"/"false"
      } else {
        form.fields.add(MapEntry(k, v.toString())); // add as string
      }
    });

    // Add image if provided
    final img = fields['image'];
    if (img is File) {
      final ext = p.extension(img.path).toLowerCase(); // e.g. ".png"
      final subtype = ext.endsWith('png')
          ? 'png'
          : (ext.endsWith('webp') ? 'webp' : 'jpeg'); // guess subtype
      form.files.add(
        MapEntry(
          'image', // backend expects @RequestPart("image")
          await MultipartFile.fromFile(
            img.path, // local path
            filename: p.basename(img.path), // file name
            contentType: MediaType('image', subtype), // mime
          ),
        ),
      );
    }

    // 🚀 Correct endpoint: PUT /api/items/{id}
    return _fetch.fetch(
      HttpMethod.put, // PUT
      '$_base/$id', // ✅ not "/update-with-image"
      data: form, // multipart payload
      headers: {
        'Authorization': 'Bearer $token', // bearer auth
        // No need to set Content-Type manually; Dio sets boundary automatically.
        // If your wrapper needs it, you can add: 'Content-Type': 'multipart/form-data'
      },
    );
  }
}
