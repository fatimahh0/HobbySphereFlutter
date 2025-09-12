// ===== lib/features/activities/Business/createActivity/data/services/create_item_service.dart =====
// Flutter 3.35.x
import 'dart:io'; // File type
import 'package:dio/dio.dart'; // FormData + Multipart
import 'package:http_parser/http_parser.dart'; // MediaType for file mime
import 'package:intl/intl.dart'; // Date formatting
import 'package:path/path.dart' as p; // Filename helpers

import 'package:hobby_sphere/core/network/api_fetch.dart'; // Your fetch wrapper
import 'package:hobby_sphere/core/network/api_methods.dart'; // HttpMethod enum

class CreateItemService {
  final _fetch = ApiFetch(); // Shared fetch instance
  static const _base = '/items'; // Base mapping from backend

  Future<Response> createMultipart(
    String token, // JWT token
    Map<String, dynamic> body, // Key-values (and optional File)
  ) async {
    final form = FormData(); // Multipart form

    String _isoNoMillis(
      DateTime dt,
    ) => // Helper to format dt as yyyy-MM-dd'T'HH:mm:ss
        DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(dt.toLocal());

    final fields = Map<String, dynamic>.from(body); // Clone to safely edit

    // Normalize DateTimes if present (safe if already string)
    if (fields['startDatetime'] is DateTime) {
      fields['startDatetime'] = _isoNoMillis(
        fields['startDatetime'] as DateTime,
      ); // Format start
    }
    if (fields['endDatetime'] is DateTime) {
      fields['endDatetime'] = _isoNoMillis(
        fields['endDatetime'] as DateTime,
      ); // Format end
    }

    // Add simple fields exactly once (includes imageUrl if provided)
    fields.forEach((k, v) {
      // Iterate all entries
      if (v == null) return; // Skip nulls
      if (v is File) return; // Skip files (added below)
      form.fields.add(MapEntry(k, v.toString())); // Add string field
    });

    // Add optional image file only once
    if (fields['image'] is File) {
      // If a File was provided
      final file = fields['image'] as File; // Cast
      form.files.add(
        // Append file part
        MapEntry(
          'image', // Field name expected by backend
          await MultipartFile.fromFile(
            file.path, // Disk path
            filename: p.basename(file.path), // Original filename
            contentType: MediaType(
              'image',
              _guess(p.extension(file.path)),
            ), // Mime subtype
          ),
        ),
      );
    }

    // Debug fields (useful when validating server params)
    print("=== DEBUG FORM FIELDS ==="); // Start marker
    for (final f in form.fields) {
      // All text fields
      print("${f.key}: ${f.value}"); // Key: value
    }
    print("========================="); // End marker

    // Send multipart request with explicit header
    return _fetch.fetch(
      HttpMethod.post, // HTTP POST
      '$_base/create', // /items/create
      data: form, // Multipart payload
      headers: {
        'Authorization': 'Bearer $token', // Bearer token
        'Content-Type': 'multipart/form-data', // Explicit multipart header
      },
    );
  }

  Future<Response> updateMultipart(
    String token, // JWT token
    int id, // Item id to update
    Map<String, dynamic> body, // Update fields
  ) async {
    final form = await _toForm(body); // Convert to FormData
    return _fetch.fetch(
      HttpMethod.put, // HTTP PUT
      '$_base/$id/update-with-image', // Update endpoint
      data: form, // Multipart
      headers: {
        'Authorization': 'Bearer $token', // Bearer token
        'Content-Type': 'multipart/form-data', // Multipart header
      },
    );
  }

  Future<FormData> _toForm(Map<String, dynamic> body) async {
    final form = FormData(); // New form
    for (final e in body.entries) {
      // Loop all entries
      final k = e.key; // Key
      final v = e.value; // Value
      if (v == null) continue; // Skip null
      if (k == 'imageRemoved') {
        // Special boolean as string
        form.fields.add(
          MapEntry(k, (v == true) ? 'true' : 'false'),
        ); // "true"/"false"
        continue; // Next entry
      }
      if (v is File) continue; // Defer files
      form.fields.add(MapEntry(k, v.toString())); // Add text
    }

    if (body['image'] is File) {
      // If file included
      final file = body['image'] as File; // Cast
      form.files.add(
        // Append file part
        MapEntry(
          'image', // Field name expected by backend
          await MultipartFile.fromFile(
            file.path, // Path
            filename: p.basename(file.path), // File name
            contentType: MediaType(
              'image',
              _guess(p.extension(file.path)),
            ), // Mime
          ),
        ),
      );
    }
    return form; // Return built form
  }

  String _guess(String ext) {
    // Guess image subtype
    final e = ext.toLowerCase(); // Normalize ext
    if (e.endsWith('png')) return 'png'; // .png
    if (e.endsWith('webp')) return 'webp'; // .webp
    return 'jpeg'; // Default jpeg
  }
}
