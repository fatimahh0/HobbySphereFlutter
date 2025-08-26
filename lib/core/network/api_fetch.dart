import 'package:dio/dio.dart'; // dio types
import 'api_client.dart'; // singleton client
import 'api_methods.dart'; // method names

class ApiFetch {
  final Dio _dio = ApiClient().dio; // reuse one dio
  CancelToken? _token; // for cancelable PATCH

  void cancel() {
    _token?.cancel('Cancelled'); // cancel with reason
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
    String method, // GET/POST/PUT/PATCH/DELETE
    String url, { // endpoint path
    dynamic data, // <-- changed here (accepts Map or FormData)
    Map<String, String>? headers,
  }) async {
    final opts = Options(headers: headers);

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
