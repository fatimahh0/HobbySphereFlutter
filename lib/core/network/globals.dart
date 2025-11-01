library globals;

import 'package:dio/dio.dart';
import 'package:hobby_sphere/core/network/interceptors/auth_body_injector.dart';

Dio? appDio;

// Core server base, e.g. https://host/api
late String appServerRoot;

// Tokens (legacy compatibility)
String? authToken;
String? token;
String? userToken;
String? Token;

// Owner / tenant wiring (filled from Env in main.dart)
String? ownerProjectLinkId; // e.g. "1-1"
String? ownerAttachMode; // "header" | "query" | "body" | "off"
String? projectId; // e.g. "1"
String? appRole; // "both" | "user" | "business"
String? wsPath; // "/api/ws"

// ---- Helpers ----
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
      baseUrl: appServerRoot,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 1),
    ),
  );
}

/// configure shared Dio with baseUrl + interceptors
void makeDefaultDio(String baseUrl) {
  final d = Dio(
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
  );

  d.interceptors.clear();
  d.interceptors.add(OwnerInjector()); // uses Env.* internally
  d.interceptors.add(
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: false,
      responseHeader: false,
    ),
  );

  appDio = d;
}
