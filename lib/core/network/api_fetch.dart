// ===== Flutter 3.35.x =====
// Simple wrapper around Dio. Supports GET/POST/... and query building.

import 'package:dio/dio.dart'; // dio types
import 'package:hobby_sphere/core/network/api_methods.dart'; // method names
import 'package:hobby_sphere/core/network/globals.dart'
    as g; // <-- use shared dio

class ApiFetch {
  // pick injected Dio if provided, else use app-wide g.appDio (set in main)
  final Dio _dio; // reuse one dio
  CancelToken? _token; // for cancelable PATCH

  // constructor: optional dio for tests/overrides; zero-arg keeps old usage
  ApiFetch([Dio? dio])
    : _dio = dio ?? g.appDio!; // use global; '!' because main sets it

  // cancel current PATCH (if any)
  void cancel() {
    _token?.cancel('Cancelled'); // cancel reason
    _token = null; // clear
  }

  // build a query string from a map (for GET)
  String _query(Map<String, dynamic>? p) {
    if (p == null || p.isEmpty) return ''; // nothing → empty
    final q = p.entries
        .map(
          (e) =>
              '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent('${e.value}')}',
        ) // key=value
        .join('&'); // join with &
    return '?$q'; // start with ?
  }

  // main fetch method
  Future<Response> fetch(
    String method, // method string (from api_methods.dart)
    String url, { // endpoint path (ex: /auth/user/login)
    dynamic data, // body or query map
    Map<String, String>? headers, // extra headers
    Duration? receiveTimeoutOverride, // optional per-call timeout
  }) async {
    // base options for this call
    final opts = Options(
      headers: headers, // merge headers if provided
      receiveTimeout:
          receiveTimeoutOverride, // per-call receive timeout (optional)
    );

    // route by method
    switch (method) {
      case HttpMethod.get:
        // GET → put query in URL
        return _dio.get('$url${_query(data)}', options: opts);

      case HttpMethod.post:
        // POST → send body as-is (Map or FormData)
        return _dio.post(url, data: data, options: opts);

      case HttpMethod.put:
        return _dio.put(url, data: data, options: opts);

      case HttpMethod.delete:
        return _dio.delete(url, data: data, options: opts);

      case HttpMethod.patch:
        _token = CancelToken(); // create cancel token
        return _dio.patch(url, data: data, options: opts, cancelToken: _token);

      default:
        throw ArgumentError('Invalid method'); // guard
    }
  }
}
