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

    // add non-file fields
    fields.forEach((k, v) {
      if (v == null) return;
      if (v is File) return;
      form.fields.add(MapEntry(k, v.toString()));
    });

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

    return _fetch.fetch(
      HttpMethod.post,
      '$_base/create', // -> /api/items/create
      data: form,
      headers: {
        'Authorization': 'Bearer $token',
        // Don't set Content-Type manually; Dio sets multipart boundary.
      },
    );
  }

  String _guess(String ext) {
    final e = ext.toLowerCase();
    if (e.endsWith('png')) return 'png';
    if (e.endsWith('webp')) return 'webp';
    return 'jpeg';
  }
}
