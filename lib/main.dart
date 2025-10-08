// lib/main.dart
// Flutter 3.35.x — single entrypoint (no duplicates).
// - Initializes Stripe (safe try/catch).
// - Builds Dio based on Env.apiBaseUrl or ApiConfig.load() fallback.
// - Exposes Dio + base URLs in globals (g.*) for the rest of the app.
// - Boots the app inside runZonedGuarded and logs uncaught errors.

import 'dart:async';
import 'dart:io'; // (optional) if you need Platform checks later
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hobby_sphere/config/env.dart';
import 'package:hobby_sphere/core/network/api_config.dart';
import 'package:hobby_sphere/core/network/globals.dart' as g;

import 'app/app.dart'; // Root widget (MaterialApp.router lives there)

Future<void> _initStripe() async {
  try {
    // TODO: replace with your live/test keys & merchant id as needed.
    Stripe.publishableKey =
        'pk_test_51RnLY8ROH9W55MgTYuuYpaStORtbLEggQMGOYxzYacMiDUpbfifBgThEzcMgFnvyMaskalQ0WUcQv08aByizug1I00Wcq3XHll';
    Stripe.urlScheme = 'flutterstripe'; // Android intent / iOS URL types
    Stripe.merchantIdentifier = 'merchant.com.hobbysphere'; // iOS merchant ID
    await Stripe.instance.applySettings();
    debugPrint('[Stripe] Initialized');
  } on PlatformException catch (e, st) {
    debugPrint(
      '[Stripe] PlatformException code=${e.code} msg=${e.message} det=${e.details}',
    );
    debugPrint('$st');
  } catch (e, st) {
    debugPrint('[Stripe] Unexpected init error: $e');
    debugPrint('$st');
  }
}

Future<void> _initNetworking() async {
  // 1) Resolve server root (prefer Env.apiBaseUrl, fallback to ApiConfig.load()).
  String serverRoot;
  if (Env.apiBaseUrl.trim().isNotEmpty) {
    var s = Env.apiBaseUrl.trim();
    // Normalize: remove trailing /api and final slashes; ensure protocol.
    if (s.endsWith('/api')) s = s.substring(0, s.length - 4);
    s = s.replaceAll(RegExp(r'/+$'), '');
    if (!s.startsWith('http://') && !s.startsWith('https://')) {
      s = 'http://$s';
    }
    serverRoot = s; // e.g. http://192.168.1.10:8080
  } else {
    final cfg = await ApiConfig.load(); // e.g. reads lib/config/hostIp.json
    serverRoot = cfg.serverRoot; // already normalized there
  }

  // 2) Build base API URL and store in globals.
  final baseWithApi = '$serverRoot/api';
  g.appServerRoot = baseWithApi; // used across the app

  // 3) Create Dio once and expose it via globals.
  final dio =
      Dio(
          BaseOptions(
            baseUrl: baseWithApi,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 60),
            sendTimeout: const Duration(seconds: 30),
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        )
        ..interceptors.add(
          LogInterceptor(
            requestBody: true,
            responseBody: true,
            requestHeader: false,
            responseHeader: false,
          ),
        );

  // 4) Restore token (if any) to keep the user signed in.
  final sp = await SharedPreferences.getInstance();
  final savedToken = sp.getString('token');
  if ((savedToken ?? '').isNotEmpty) {
    dio.options.headers['Authorization'] = 'Bearer $savedToken';
    g.token = savedToken; // keep in your globals if you use them elsewhere
  }

  g.appDio = dio; // make it available globally
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Surface all framework errors to the console in dev.
  FlutterError.onError = (details) {
    FlutterError.dumpErrorToConsole(details);
  };

  await runZonedGuarded(
    () async {
      await _initStripe();
      await _initNetworking();
      runApp(const App()); // App builds MaterialApp.router
    },
    (error, stack) {
      debugPrint('UNCAUGHT: $error');
      debugPrintStack(stackTrace: stack);
    },
  );
}
