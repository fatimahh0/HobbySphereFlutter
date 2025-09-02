import 'package:dio/dio.dart';
import 'package:hobby_sphere/core/network/api_fetch.dart';
import 'package:hobby_sphere/core/network/api_methods.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:intl/intl.dart';

class UpdatedItemService {
  final _fetch = ApiFetch();
  static const _base = '/items';

  Future<Response> updateMultipart(
    String token,
    int id,
    Map<String, dynamic> body,
  ) async {
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

    final form = FormData();

    // fields (booleans as strings)
    fields.forEach((k, v) {
      if (v == null) return;
      if (v is File) return;
      if (v is bool) {
        form.fields.add(MapEntry(k, v ? 'true' : 'false'));
      } else {
        form.fields.add(MapEntry(k, v.toString()));
      }
    });

    // image
    if (fields['image'] is File) {
      final file = fields['image'] as File;
      final ext = p.extension(file.path).toLowerCase();
      final subtype = ext.endsWith('png')
          ? 'png'
          : (ext.endsWith('webp') ? 'webp' : 'jpeg');
      form.files.add(
        MapEntry(
          'image',
          await MultipartFile.fromFile(
            file.path,
            filename: p.basename(file.path),
            contentType: MediaType('image', subtype),
          ),
        ),
      );
    }

    return _fetch.fetch(
      HttpMethod.put,
      '$_base/$id/update-with-image',
      data: form,
      headers: {'Authorization': 'Bearer $token'},
    );
  }
}
