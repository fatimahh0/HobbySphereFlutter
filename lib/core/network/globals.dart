// lib/core/network/globals.dart
library globals;

import 'package:dio/dio.dart';

/// Shared HTTP client (set it once in main()).
Dio? appDio;

/// Base API root, e.g. http://host:port/api
String? appServerRoot;

/// Multiple token aliases so old/new code both work.
String? authToken;
String? token;
String? userToken;
String? Token; // if you already set this one in main()

/// Read a token safely (picks the first non-empty).
String readAuthToken() {
  return (authToken ?? token ?? userToken ?? Token ?? '').toString();
}

/// Root without trailing `/api` (handy for building absolute image URLs).
String serverRootNoApi() {
  final base = (appServerRoot ?? '').toString();
  return base.replaceFirst(RegExp(r'/api/?$'), '');
}

/// Ensure a Dio instance exists.
Dio dio() {
  return appDio ??= Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 1),
    ),
  );
}
