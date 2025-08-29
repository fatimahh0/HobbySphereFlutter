// ===== Flutter 3.35.x =====
// globals.dart — one shared Dio holder (not a class static).
// We set it once in main(), then any screen can read it.

import 'package:dio/dio.dart'; // dio http client

Dio? appDio; // nullable until main() sets it

// add this next to appDio
String? appServerRoot; // set once in main() after loading ApiConfig
