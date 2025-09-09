import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

import 'package:hobby_sphere/core/network/api_fetch.dart';
import 'package:hobby_sphere/core/network/api_methods.dart';

class CreateItemService {
  final _fetch = ApiFetch();
  static const _base = '/items'; // matches @RequestMapping("/api/items")

  Future<Response> createMultipart(
    String token,
    Map<String, dynamic> body,
  ) async {
    final form = FormData();

    // ensure ISO-8601 for Spring LocalDateTime (no 'Z', no millis)
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

    // ✅ Add non-file fields
    fields.forEach((k, v) {
      if (v == null) return;
      if (v is File) return;
      form.fields.add(MapEntry(k, v.toString()));
    });

    // ✅ Explicitly handle old imageUrl
    if (fields['imageUrl'] != null &&
        fields['imageUrl'].toString().isNotEmpty) {
      form.fields.add(MapEntry('imageUrl', fields['imageUrl'].toString()));
    }

    // add optional image
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

    print("=== DEBUG FORM FIELDS ===");
    for (final f in form.fields) {
      print("${f.key}: ${f.value}");
    }
    print("=========================");

    return _fetch.fetch(
      HttpMethod.post,
      '$_base/create',
      data: form,
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<Response> updateMultipart(
    String token,
    int id,
    Map<String, dynamic> body,
  ) async {
    final form = await _toForm(body);
    return _fetch.fetch(
      HttpMethod.put,
      '$_base/$id/update-with-image',
      data: form,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'multipart/form-data',
      },
    );
  }

  Future<FormData> _toForm(Map<String, dynamic> body) async {
    final form = FormData();
    for (final e in body.entries) {
      final k = e.key;
      final v = e.value;
      if (v == null) continue;
      if (k == 'imageRemoved') {
        // booleans must be strings for some servers
        form.fields.add(MapEntry(k, (v == true) ? 'true' : 'false'));
        continue;
      }
      if (v is File) continue; // handled below
      form.fields.add(MapEntry(k, v.toString()));
    }

    if (body['image'] is File) {
      final file = body['image'] as File;
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
    return form;
  }

  String _guess(String ext) {
    final e = ext.toLowerCase();
    if (e.endsWith('png')) return 'png';
    if (e.endsWith('webp')) return 'webp';
    return 'jpeg';
  }
}
