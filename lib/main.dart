// lib/main.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hobby_sphere/core/network/api_config.dart';
import 'package:hobby_sphere/core/network/api_client.dart';
import 'package:hobby_sphere/core/network/globals.dart' as g;


// import 'package:hobby_sphere/core/realtime/realtime_service.dart';

import 'package:flutter_stripe/flutter_stripe.dart';
import 'app/app.dart';

Future<void> main() async {

  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      
      try {
     
        Stripe.publishableKey =
            'pk_test_51RnLY8ROH9W55MgTYuuYpaStORtbLEggQMGOYxzYacMiDUpbfifBgThEzcMgFnvyMaskalQ0WUcQv08aByizug1I00Wcq3XHll';

    
        await Stripe.instance.applySettings();
        if (kDebugMode) debugPrint('[Stripe] initialized');
      } catch (e, st) {
       
        debugPrint('[Stripe] init failed: $e\n$st');
      }
      // -------------------------------------------------------------------

   
      final cfg = await ApiConfig.load();
      final apiClient = ApiClient(cfg);

      final sp = await SharedPreferences.getInstance();
      final savedToken = sp.getString('token');

      if (savedToken != null && savedToken.isNotEmpty) {
        apiClient.setToken(savedToken);
        g.Token = savedToken;
      }

      g.appDio = apiClient.dio;
      g.appServerRoot = cfg.serverRoot;

    
      // final httpBase = g.serverRootNoApi();
      // if ((savedToken ?? '').isNotEmpty) {
      //   g.realtime ??= RealtimeService();
      //   g.realtime!.connect(
      //     httpBase: httpBase,
      //     token: savedToken!,
      //     candidatePaths: const ['/ws', '/ws/events', '/realtime', '/socket'],
      //   );
      // }

      runApp(const App());
    },
    (error, stack) {
    
      debugPrint('UNCAUGHT in main zone: $error\n$stack');
    },
  );
}
