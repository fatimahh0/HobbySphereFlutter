// ===== Flutter 3.35.x =====
// lib/core/network/api_client.dart
// One Dio client for all requests. Bigger timeouts. Base URL from ApiConfig.

import 'package:dio/dio.dart'; // http client
import 'package:hobby_sphere/core/network/api_config.dart'; // loads hostIp.json

class ApiClient {
  // singleton pattern (one instance)
  static final ApiClient _i = ApiClient._(); // private instance
  factory ApiClient() => _i; // factory getter
  ApiClient._(); // private ctor

  late final Dio dio =
      Dio(
          BaseOptions(
            baseUrl:
                ApiConfig.baseUrl, // base url (ex: http://10.0.2.2:8080/api)
            connectTimeout: const Duration(seconds: 30), // connect timeout 30s
            receiveTimeout: const Duration(seconds: 60), // receive timeout 60s
            sendTimeout: const Duration(seconds: 30), // send timeout 30s
            headers: const {
              'Content-Type': 'application/json', // send json by default
              'Accept': 'application/json', // expect json back
            },
          ),
        )
        // optional: simple logging to console
        ..interceptors.add(
          LogInterceptor(
            requestBody: true, // log request body
            responseBody: true, // log response body
            requestHeader: false, // no need headers noise
            responseHeader: false, // no headers
          ),
        );

  // set bearer token for all calls after login
  void setToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token'; // attach JWT
  }

  // allow changing baseUrl at runtime after ApiConfig.load()
  void refreshBaseUrl() {
    dio.options.baseUrl = ApiConfig.baseUrl; // set new base url
  }
}
