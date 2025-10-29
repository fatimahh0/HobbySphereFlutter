// lib/core/network/api_client.dart
import 'package:dio/dio.dart';
import 'package:hobby_sphere/core/network/api_config.dart';
import 'package:hobby_sphere/core/network/interceptors/auth_body_injector.dart';

class ApiClient {
  final Dio dio;

  ApiClient(ApiConfig config)
    : dio =
          Dio(
              BaseOptions(
                baseUrl: config.baseUrl,
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 60),
                sendTimeout: const Duration(seconds: 30),
                headers: const {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            )
            ..interceptors.addAll([
              OwnerInjector(),
              LogInterceptor(
                requestBody: true,
                responseBody: true,
                requestHeader: false,
                responseHeader: false,
              ),
            ]);

  void setToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }
}
