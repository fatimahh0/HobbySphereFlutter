// Flutter 3.35.x — simple and clean
import 'dart:io'; // File
import 'package:dio/dio.dart'; // FormData
import 'package:http_parser/http_parser.dart'; // MediaType
import 'package:intl/intl.dart'; // DateFormat
import 'package:path/path.dart' as p; // basename

import 'package:hobby_sphere/core/network/api_fetch.dart'; // ApiFetch
import 'package:hobby_sphere/core/network/api_methods.dart'; // HttpMethod

class CreateItemService {
  final _fetch = ApiFetch(); // HTTP client
  static const _base = '/items'; // base path => maps to /api/items

  // ==== CREATE (POST /api/items) ====
  Future<Response> createMultipart(
    String token, // bearer
    Map<String, dynamic> body, // fields + optional 'image' File
  ) async {
    final form = FormData(); // multipart form

    // helper for ISO without millis (backend expects ISO.DATE_TIME)
    String _isoNoMillis(DateTime dt) =>
        DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(dt.toLocal());

    // clone so we can transform
    final fields = Map<String, dynamic>.from(body);

    // normalize dates to string if DateTime given
    if (fields['startDatetime'] is DateTime) {
      fields['startDatetime'] = _isoNoMillis(
        fields['startDatetime'] as DateTime,
      );
    }
    if (fields['endDatetime'] is DateTime) {
      fields['endDatetime'] = _isoNoMillis(fields['endDatetime'] as DateTime);
    }

    // add text fields (skip nulls/files)
    fields.forEach((k, v) {
      if (v == null) return; // skip null
      if (v is File) return; // skip file (handled below)
      form.fields.add(MapEntry(k, v.toString())); // add as text
    });

    // add file if present under 'image'
    final img = body['image'];
    if (img is File) {
      form.files.add(
        MapEntry(
          'image', // controller expects @RequestPart("image")
          await MultipartFile.fromFile(
            img.path,
            filename: p.basename(img.path),
            contentType: MediaType('image', _guess(p.extension(img.path))),
          ),
        ),
      );
    }

    // send POST to /items (NOT /items/create)
    return _fetch.fetch(
      HttpMethod.post,
      _base, // -> /api/items
      data: form,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'multipart/form-data',
      },
    );
  }

  // ==== UPDATE (PUT /api/items/{id}) ====
  Future<Response> updateMultipart(
    String token,
    int id,
    Map<String, dynamic> body,
  ) async {
    final form = await _toForm(
      body,
    ); // build form (handles imageRemoved + file)
    return _fetch.fetch(
      HttpMethod.put,
      '$_base/$id', // -> /api/items/{id}
      data: form,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'multipart/form-data',
      },
    );
  }

  // helper: body -> FormData (for update)
  Future<FormData> _toForm(Map<String, dynamic> body) async {
    final form = FormData(); // new form

    // convert dates if passed as DateTime
    String _isoNoMillis(DateTime dt) =>
        DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(dt.toLocal());

    final fields = Map<String, dynamic>.from(body);

    if (fields['startDatetime'] is DateTime) {
      fields['startDatetime'] = _isoNoMillis(
        fields['startDatetime'] as DateTime,
      );
    }
    if (fields['endDatetime'] is DateTime) {
      fields['endDatetime'] = _isoNoMillis(fields['endDatetime'] as DateTime);
    }

    for (final e in fields.entries) {
      final k = e.key;
      final v = e.value;
      if (v == null) continue; // skip null
      if (v is File) continue; // handle file below
      if (k == 'imageRemoved') {
        // backend expects boolean, send as "true"/"false"
        form.fields.add(MapEntry(k, (v == true) ? 'true' : 'false'));
      } else {
        form.fields.add(MapEntry(k, v.toString()));
      }
    }

    // optional image
    if (fields['image'] is File) {
      final file = fields['image'] as File;
      form.files.add(
        MapEntry(
          'image',
          await MultipartFile.fromFile(
            file.path,
            filename: p.basename(file.path),
            contentType: MediaType('image', _guess(p.extension(file.path))),
          ),
        ),
      );
    }

    return form; // done
  }

  String _guess(String ext) {
    final e = ext.toLowerCase();
    if (e.endsWith('png')) return 'png';
    if (e.endsWith('webp')) return 'webp';
    return 'jpeg'; // default
  }
}
