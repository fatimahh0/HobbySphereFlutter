// lib/core/network/api_fetch.dart
import 'package:dio/dio.dart';
import 'package:hobby_sphere/core/network/api_methods.dart';
import 'package:hobby_sphere/core/network/globals.dart' as g;

class ApiFetch {
  final Dio _dio;
  CancelToken? _token;

  ApiFetch([Dio? dio])
    : _dio =
          dio ??
          (g.appDio ??
              (throw StateError(
                'Api not initialized: g.appDio is null. '
                'Call _initNetworking() before using ApiFetch, or pass a Dio to ApiFetch().',
              )));

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
    ResponseType? responseType,
  }) async {
    final opts = Options(
      headers: headers,
      receiveTimeout: receiveTimeoutOverride,
      responseType: responseType,
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
