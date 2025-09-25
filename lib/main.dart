// lib/main.dart
import 'dart:async'; // zone
import 'dart:io'; // Platform check (Android/iOS)
import 'package:flutter/foundation.dart'; // debugPrint
import 'package:flutter/material.dart'; // UI
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart'; // Stripe SDK

import 'package:shared_preferences/shared_preferences.dart'; // prefs
import 'package:hobby_sphere/core/network/api_config.dart'; // cfg
import 'package:hobby_sphere/core/network/api_client.dart'; // dio client
import 'package:hobby_sphere/core/network/globals.dart' as g; // globals
import 'app/app.dart'; // root widget

Future<void> main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized(); // init Flutter
      try {
        Stripe.publishableKey =
            'pk_test_51RnLY8ROH9W55MgTYuuYpaStORtbLEggQMGOYxzYacMiDUpbfifBgThEzcMgFnvyMaskalQ0WUcQv08aByizug1I00Wcq3XHll'; // test key
        Stripe.urlScheme = 'flutterstripe'; // must match Manifest scheme
        Stripe.merchantIdentifier =
            'merchant.com.hobbysphere'; // iOS ok on Android

        await Stripe.instance.applySettings(); // initialize the plugin
        debugPrint('[Stripe] init OK'); // log success
      } on PlatformException catch (e, st) {
        debugPrint(
          '[Stripe] init FAIL code=${e.code} msg=${e.message} details=${e.details}',
        );
        debugPrint('$st'); // log full stack
      } catch (e, st) {
        debugPrint('[Stripe] init FAIL unexpected: $e\n$st');
      }

      // ---- your existing boot logic (unchanged) ----
      final cfg = await ApiConfig.load(); // load server cfg
      final apiClient = ApiClient(cfg); // build dio
      final sp = await SharedPreferences.getInstance(); // prefs
      final savedToken = sp.getString('token'); // jwt from storage
      if ((savedToken ?? '').isNotEmpty) {
        apiClient.setToken(savedToken!); // set on client
        g.Token = savedToken; // cache in globals
      }
      g.appDio = apiClient.dio; // expose dio
      g.appServerRoot = cfg.serverRoot; // expose base
      runApp(const App()); // start app
    },
    (error, stack) {
      debugPrint('UNCAUGHT in main zone: $error\n$stack'); // safety
    },
  );
}
