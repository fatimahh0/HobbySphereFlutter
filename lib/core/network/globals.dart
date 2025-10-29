// lib/core/network/globals.dart (snippet)
import 'package:dio/dio.dart';

import 'package:hobby_sphere/core/network/interceptors/auth_body_injector.dart';

late Dio appDio;

void makeDefaultDio(String baseUrl) {
  appDio =
      Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 60),
            sendTimeout: const Duration(seconds: 30),
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        )
        ..interceptors.clear()
        ..interceptors.addAll([
          OwnerInjector(), // ⬅️ only this one
          LogInterceptor(
            requestBody: true,
            responseBody: true,
            requestHeader: false,
            responseHeader: false,
          ),
        ]);
}
