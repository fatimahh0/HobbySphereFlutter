import 'dart:convert'; // decode JSON text
import 'package:flutter/services.dart'; // read assets

class ApiConfig {
  static String? _baseUrl; // cached base url after load

  static String get baseUrl => // getter used by Dio
      _baseUrl ?? 'http://10.0.2.2:8080/api'; // default for emulator

  static Future<void> load() async {
    final raw = await rootBundle.loadString(
      'lib/config/hostIp.json',
    ); // read file
    final map = jsonDecode(raw) as Map<String, dynamic>; // parse json
    final host =
        map['serverURI'] as String? ?? 'http://10.0.2.2:8080'; // fallback
    _baseUrl = '$host/api'; // build final base url
  }
}
