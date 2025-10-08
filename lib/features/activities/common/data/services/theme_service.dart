// Fetch the active mobile theme JSON from backend.
// Works with your global Dio and token. Falls back safely.

import 'dart:convert'; // jsonDecode
import 'package:dio/dio.dart'; // HTTP
import 'package:hobby_sphere/core/network/globals.dart'
    as g; // appDio, Token, serverRoot

class ThemeService {
  // use the global dio if set; else create one
  Dio get _dio => g.appDio ?? Dio();

  // API path: .../api/themes/active/mobile
  String get _url => '${g.appServerRoot}/themes/active/mobile';

  // GET and return a Map<String, dynamic>
  Future<Map<String, dynamic>> getActiveMobileTheme() async {
    // headers (only Authorization if token exists)
    final headers = <String, dynamic>{};
    if ((g.Token ?? '').isNotEmpty) {
      headers['Authorization'] = 'Bearer ${g.Token}';
    }

    // do the request
    final res = await _dio.get(_url, options: Options(headers: headers));

    // if backend returned a map directly
    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      return res.data as Map<String, dynamic>;
    }

    // if backend returned a JSON string
    if (res.statusCode == 200 && res.data is String) {
      return jsonDecode(res.data as String) as Map<String, dynamic>;
    }

    // any other case => throw simple error
    throw Exception('Failed to load mobile theme');
  }
}
