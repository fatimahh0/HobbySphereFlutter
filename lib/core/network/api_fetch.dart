// lib/core/network/api_fetch.dart
// ===== Flutter 3.35.x =====
// Simple wrapper around Dio. Adds optional `responseType`.

import 'package:dio/dio.dart';
import 'package:hobby_sphere/core/network/api_methods.dart';
import 'package:hobby_sphere/core/network/globals.dart' as g;

class ApiFetch {
  final Dio _dio;
  CancelToken? _token;

  ApiFetch([Dio? dio]) : _dio = dio ?? g.appDio!;

  void cancel() {
    _token?.cancel('Cancelled');
    _token = null;
  }

  String _query(Map<String, dynamic>? p) {
    if (p == null || p.isEmpty) return '';
    final q = p.entries
        .map(
          (e) =>
              '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent('${e.value}')}',
        )
        .join('&');
    return '?$q';
  }

  Future<Response> fetch(
    String method,
    String url, {
    dynamic data,
    Map<String, String>? headers,
    Duration? receiveTimeoutOverride,
    ResponseType? responseType, // ⬅ NEW
  }) async {
    final opts = Options(
      headers: headers,
      receiveTimeout: receiveTimeoutOverride,
      responseType: responseType, // ⬅ NEW
    );

    switch (method) {
      case HttpMethod.get:
        return _dio.get('$url${_query(data)}', options: opts);
      case HttpMethod.post:
        return _dio.post(url, data: data, options: opts);
      case HttpMethod.put:
        return _dio.put(url, data: data, options: opts);
      case HttpMethod.delete:
        return _dio.delete(url, data: data, options: opts);
      case HttpMethod.patch:
        _token = CancelToken();
        return _dio.patch(url, data: data, options: opts, cancelToken: _token);
      default:
        throw ArgumentError('Invalid method');
    }
  }
}
