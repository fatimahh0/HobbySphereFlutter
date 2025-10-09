// lib/app/main_products.dart
// Flutter 3.35.x — Product standalone entry

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hobby_sphere/config/env.dart';
import 'package:hobby_sphere/features/products/app_router_product.dart';

import 'package:hobby_sphere/core/network/globals.dart' as g;

import 'package:hobby_sphere/shared/theme/app_theme.dart';
import 'package:hobby_sphere/shared/network/connection_cubit.dart';

Future<void> _initNetworking() async {
  // API_BASE_URL e.g. "http://192.168.1.8:8080"
  final root = Env.apiBaseUrl.trim().replaceAll(RegExp(r'/+$'), '');
  final baseWithApi = '$root/api';
  g.appServerRoot = baseWithApi;
  g.makeDefaultDio(baseWithApi); // <-- helper we added in globals.dart
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) => FlutterError.dumpErrorToConsole(details);

  await runZonedGuarded(
    () async {
      await _initNetworking();
      runApp(const ProductApp());
    },
    (e, st) {
      debugPrint('UNCAUGHT: $e');
      debugPrintStack(stackTrace: st);
    },
  );
}

class ProductApp extends StatelessWidget {
  const ProductApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = buildProductRouter();

    final healthUrl =
        g.appServerRoot.replaceFirst(RegExp(r'/api/?$'), '') +
        '/actuator/health';

    return BlocProvider(
      create: (_) => ConnectionCubit(serverProbeUrl: healthUrl),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Hobby Sphere — Product',
        routerConfig: router,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
      ),
    );
  }
}
