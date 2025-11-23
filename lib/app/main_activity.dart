// lib/app/main_activity.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'package:hobby_sphere/config/env.dart';
import 'package:hobby_sphere/core/network/api_config.dart';
import 'package:hobby_sphere/core/network/globals.dart' as g;

import 'package:hobby_sphere/app/router/router.dart' as app_router;
import 'package:hobby_sphere/l10n/app_localizations.dart' show AppLocalizations;
import 'package:hobby_sphere/shared/theme/app_theme.dart';
import 'package:hobby_sphere/shared/theme/theme_cubit.dart';

import 'package:hobby_sphere/shared/network/connection_cubit.dart';

Future<void> _initStripe() async {
  try {
    final pk = (Env.stripePublishableKey).trim();
    if (pk.isEmpty) throw StateError('Env.stripePublishableKey is empty');

    Stripe.publishableKey = pk;
    Stripe.urlScheme = 'flutterstripe';
    Stripe.merchantIdentifier = 'merchant.com.hobbysphere'; // iOS only
    await Stripe.instance.applySettings();

    debugPrint(
      '[Stripe] Initialized (${pk.startsWith("pk_live_") ? "LIVE" : "TEST"})',
    );
  } on PlatformException catch (e, st) {
    debugPrint(
      '[Stripe] PlatformException: ${e.code} ${e.message} ${e.details}',
    );
    debugPrint('$st');
  } catch (e, st) {
    debugPrint('[Stripe] Init error: $e');
    debugPrint('$st');
  }
}

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

  // multi-tenant globals
  g.wsPath = Env.wsPath;
  g.ownerProjectLinkId = Env.ownerProjectLinkId;
  g.projectId = Env.projectId;
  g.appRole = Env.appRole;
  g.ownerAttachMode = Env.ownerAttachMode;

  // ---------- BRANDING ----------
  g.appName = Env.appName.trim().isEmpty
      ? 'Hobby Sphere — Activity'
      : Env.appName.trim();

  final rawLogo = Env.appLogoUrl.trim();
  g.appLogoUrl = rawLogo.isEmpty
      ? ''
      : (rawLogo.startsWith('http')
            ? rawLogo
            : '${serverRoot.replaceAll(RegExp(r"/$"), "")}'
                  '${rawLogo.startsWith("/") ? "" : "/"}$rawLogo');
  debugPrint('[Branding] appName=${g.appName} logo=${g.appLogoUrl}');

  // shared Dio
  g.makeDefaultDio(baseWithApi); // sets g.appDio
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.dumpErrorToConsole(details);
  };

  await runZonedGuarded(
    () async {
      await _initStripe();
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

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ConnectionCubit(serverProbeUrl: healthUrl)),
        BlocProvider(
          create: (_) => ThemeCubit(
            dio: g.appDio!, // reuse shared Dio
            themeEndpoint: '/themes/active/mobile',
          )..loadRemoteTheme(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: g.appName,
            routerConfig: router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: themeState.themeData,
            darkTheme: AppTheme.dark(),
            themeMode: ThemeMode.system,
          );
        },
      ),
    );
  }
}
