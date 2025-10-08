import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hobby_sphere/config/env.dart';
import 'package:hobby_sphere/core/network/api_config.dart';
import 'package:hobby_sphere/core/network/globals.dart' as g;

import 'package:hobby_sphere/app/router/router.dart' as app_router;
import 'package:hobby_sphere/l10n/app_localizations.dart' show AppLocalizations;
import 'package:hobby_sphere/shared/theme/app_theme.dart' show AppTheme;
import 'package:hobby_sphere/shared/network/connection_cubit.dart';

Future<void> _initNetworking() async {
  String serverRoot;

  if (Env.apiBaseUrl.trim().isNotEmpty) {
    var s = Env.apiBaseUrl.trim();
    if (s.endsWith('/api')) s = s.substring(0, s.length - 4);
    s = s.replaceAll(RegExp(r'/+$'), '');
    if (!s.startsWith('http://') && !s.startsWith('https://')) {
      s = 'http://$s';
    }
    serverRoot = s; // e.g. http://192.168.1.4:8080
  } else {
    final cfg = await ApiConfig.load(); // fallback lib/config/hostIp.json
    serverRoot = cfg.serverRoot;
  }

  final baseWithApi = '$serverRoot/api';
  g.appServerRoot = baseWithApi;

  g.appDio =
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
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  
  FlutterError.onError = (details) {
    FlutterError.dumpErrorToConsole(details);
  };

  await runZonedGuarded(
    () async {
      await _initNetworking();
      runApp(const ActivityApp());
    },
    (e, st) {
      debugPrint('UNCAUGHT: $e');
      debugPrintStack(stackTrace: st);
    },
  );
}

class ActivityApp extends StatelessWidget {
  const ActivityApp({super.key});

  @override
  Widget build(BuildContext context) {
  
    final router = app_router.AppRouter.build(
      enabledFeatures: const ['activity'],
      onToggleTheme: () {},
      onChangeLocale: (_) {},
      getCurrentLocale: () => const Locale('en'),
    );

    
    final healthUrl =
        (g.appServerRoot).replaceFirst(RegExp(r'/api/?$'), '') +
        '/actuator/health';

    return BlocProvider(
      create: (_) => ConnectionCubit(serverProbeUrl: healthUrl),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Hobby Sphere — Activity',
        routerConfig: router,

        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,

    
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
      ),
    );
  }
}
