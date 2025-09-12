// lib/core/network/globals.dart

library globals;

import 'package:dio/dio.dart';
import 'package:hobby_sphere/core/realtime/realtime_service.dart';

// Shared HTTP client (set once in main()).
Dio? appDio;

//  Base API root is required after main() sets it, so make it non-nullable.
late String appServerRoot; // e.g. "http://host:8080/api"

// Multiple token aliases so old/new code both work.
String? authToken;
String? token;
String? userToken;
String? Token;

// Realtime singleton instance (nullable until connected).
RealtimeService? realtime;

// Read a token safely (picks the first non-empty).
String readAuthToken() {
  return (authToken ?? token ?? userToken ?? Token ?? '').toString();
}

// Root without trailing `/api` (now appServerRoot is guaranteed set after main()).
String serverRootNoApi() {
  // no '??' needed because appServerRoot is late non-null
  final base = appServerRoot; // already a String
  return base.replaceFirst(RegExp(r'/api/?$'), '');
}

// Ensure a Dio instance exists.
Dio dio() {
  return appDio ??= Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 1),
    ),
  );
}
