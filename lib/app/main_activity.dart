import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Stripe
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'package:hobby_sphere/config/env.dart';
import 'package:hobby_sphere/core/network/api_config.dart';
import 'package:hobby_sphere/core/network/globals.dart' as g;

import 'package:hobby_sphere/app/router/router.dart' as app_router;
import 'package:hobby_sphere/l10n/app_localizations.dart' show AppLocalizations;
import 'package:hobby_sphere/shared/theme/app_theme.dart' show AppTheme;
import 'package:hobby_sphere/shared/network/connection_cubit.dart';

Future<void> _initStripe() async {
  try {
    final pk = (Env.stripePublishableKey).trim();
    if (pk.isEmpty) throw StateError('Env.stripePublishableKey is empty');

    Stripe.publishableKey = pk;
    Stripe.urlScheme = 'flutterstripe';
    Stripe.merchantIdentifier =
        'merchant.com.hobbysphere'; // iOS only (optional)
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

  // ✅ make owner/project available globally for all screens/services
  g.wsPath = Env.wsPath; // usually /api/ws
  g.ownerProjectLinkId = Env.ownerProjectLinkId; // e.g. "1-1"
  g.projectId = Env.projectId;
  g.appRole = Env.appRole;
  g.ownerAttachMode = Env.ownerAttachMode; // 'header'|'query'|'body'|'off'

  // ✅ use our shared builder so interceptors are attached
  g.makeDefaultDio(baseWithApi);
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
