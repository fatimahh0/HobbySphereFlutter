library globals;

import 'package:dio/dio.dart';
import 'package:hobby_sphere/core/network/interceptors/tenant_interceptor.dart';
import 'package:hobby_sphere/core/network/interceptors/auth_body_injector.dart';
import 'package:hobby_sphere/core/realtime/realtime_service.dart';

Dio? appDio;
late String appServerRoot;

String? authToken;
String? token;
String? userToken;
String? Token;

RealtimeService? realtime;

String readAuthToken() {
  return (authToken ?? token ?? userToken ?? Token ?? '').toString();
}

String serverRootNoApi() {
  final base = appServerRoot;
  return base.replaceFirst(RegExp(r'/api/?$'), '');
}

Dio dio() {
  return appDio ??= Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 1),
    ),
  );
}

/// NEW: configure shared Dio with baseUrl + interceptors
// lib/core/network/globals.dart (أو مكان تهيئة Dio)
void makeDefaultDio(String baseUrl) {
  appDio = Dio(
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
      OwnerInjector(), // 👈 هذا فقط يكفي
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: false,
        responseHeader: false,
      ),
    ]);
}

