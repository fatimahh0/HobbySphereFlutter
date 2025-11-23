// lib/config/env.dart
import 'dart:convert';

class Env {
  /// Base REST, e.g. http://192.168.1.7:8080  (without trailing /api)
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  /// WS path
  static const wsPath = String.fromEnvironment(
    'WS_PATH',
    defaultValue: '/api/ws',
  );

  /// Which shell/tabs to show in the app
  static const appRole = String.fromEnvironment(
    'APP_ROLE',
    defaultValue: 'both',
  );

  /// 🔑 Tenant/owner link id (e.g., "1-1")
  static const ownerProjectLinkId = String.fromEnvironment(
    'OWNER_PROJECT_LINK_ID',
    defaultValue: '',
  );

  /// 🔑 Pure project id (for catalog filtering)
  static const projectId = String.fromEnvironment(
    'PROJECT_ID',
    defaultValue: '',
  );

  // 3rd-party keys
  static const locationIqKey = String.fromEnvironment(
    'LOCATIONIQ_KEY',
    defaultValue: 'pk.14ea0e02d4685f88a3ec5ea23dd898b9',
  );

  static const stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: 'pk_test_51RnLY8ROH9W55MgT...', // replace in CI
  );

  /// Where to attach IDs: 'header' | 'query' | 'body' | 'off'
  static const ownerAttachMode = String.fromEnvironment(
    'OWNER_ATTACH_MODE',
    defaultValue: 'header',
  );

  /// 🔥 dynamic branding
  static const appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'build4all',
  );

  static const appLogoUrl = String.fromEnvironment(
    'APP_LOGO_URL',
    defaultValue: '',
  );

  /// 🎨 Theme id (for backend reference only, optional)
  static const themeId = String.fromEnvironment('THEME_ID', defaultValue: '');

  /// 🎨 Raw theme JSON passed from CI (stringified)
  ///
  /// Set in CI as:
  ///   --dart-define=THEME_JSON="$THEME_JSON"
  static const themeJsonRaw = String.fromEnvironment(
    'THEME_JSON',
    defaultValue: '',
  );

  /// Runtime helper: parsed theme JSON (or null if missing/invalid)
  static Map<String, dynamic>? get themeJson {
    if (themeJsonRaw.isEmpty) return null;
    try {
      final decoded = jsonDecode(themeJsonRaw);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (_) {
      // If it's invalid JSON, fail-soft and ignore theme.
      return null;
    }
  }

  // ---------- Helpers ----------

  static String requiredVar(String value, String name) {
    if (value.isEmpty) {
      throw StateError('Missing: $name. Use --dart-define=$name=...');
    }
    return value;
  }

  static Uri api(String path, {Map<String, String>? query}) {
    final base = requiredVar(apiBaseUrl, 'API_BASE_URL');
    final normalized = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$base$normalized');

    if (ownerAttachMode == 'query') {
      final qp = Map<String, String>.from(query ?? {});
      if (ownerProjectLinkId.trim().isNotEmpty) {
        qp['ownerProjectLinkId'] = requiredVar(
          ownerProjectLinkId,
          'OWNER_PROJECT_LINK_ID',
        );
      }
      if (projectId.trim().isNotEmpty) {
        qp['projectId'] = requiredVar(projectId, 'PROJECT_ID');
      }
      return uri.replace(queryParameters: {...uri.queryParameters, ...qp});
    }

    if (query?.isNotEmpty == true) {
      return uri.replace(queryParameters: {...uri.queryParameters, ...query!});
    }
    return uri;
  }

  static Map<String, String> tenantHeaders({Map<String, String>? extra}) {
    if (ownerAttachMode == 'header' && ownerProjectLinkId.trim().isNotEmpty) {
      final ownerId = requiredVar(ownerProjectLinkId, 'OWNER_PROJECT_LINK_ID');
      return {
        'Content-Type': 'application/json',
        'X-Owner-Project-Id': ownerId,
        if (extra != null) ...extra,
      };
    }
    return {'Content-Type': 'application/json', if (extra != null) ...extra};
  }

  static Map<String, String> projectHeaders({Map<String, String>? extra}) {
    if (ownerAttachMode == 'header' && projectId.trim().isNotEmpty) {
      final pid = requiredVar(projectId, 'PROJECT_ID');
      return {
        'Content-Type': 'application/json',
        'X-Project-Id': pid,
        if (extra != null) ...extra,
      };
    }
    return {'Content-Type': 'application/json', if (extra != null) ...extra};
  }

  static String get wsUrl {
    final base = requiredVar(apiBaseUrl, 'API_BASE_URL');
    final scheme = base.startsWith('https') ? 'wss' : 'ws';
    final wsBase = base.replaceFirst(RegExp(r'^https?'), scheme);

    final qp = <String, String>{};
    if (ownerProjectLinkId.trim().isNotEmpty) {
      qp['ownerProjectLinkId'] = requiredVar(
        ownerProjectLinkId,
        'OWNER_PROJECT_LINK_ID',
      );
    }
    if (projectId.trim().isNotEmpty) {
      qp['projectId'] = requiredVar(projectId, 'PROJECT_ID');
    }
    final qs = qp.entries
        .map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');
    return '$wsBase$wsPath${qs.isEmpty ? '' : '?$qs'}';
  }

  static bool get hasOwner => ownerProjectLinkId.trim().isNotEmpty;
  static bool get hasProject => projectId.trim().isNotEmpty;

  static String get locationIqAutocomplete =>
      'https://api.locationiq.com/v1/autocomplete?key=$locationIqKey';
  static String get locationIqSearch =>
      'https://api.locationiq.com/v1/search?key=$locationIqKey';
  static String get locationIqReverse =>
      'https://us1.locationiq.com/v1/reverse?key=$locationIqKey';
}
