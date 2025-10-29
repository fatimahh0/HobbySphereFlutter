// lib/app/env.dart
class Env {
  /// Base REST, e.g. http://192.168.1.7:8080
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

  /// 🔑 Tenant/owner link id (for user/business multi-tenant APIs)
  static const ownerProjectLinkId = String.fromEnvironment(
    'OWNER_PROJECT_LINK_ID',
    defaultValue: '',
  );

  /// 🔑 NEW: pure project id (for catalog: Category / ItemType)
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
    defaultValue:
        'pk_test_51RnLY8ROH9W55MgTYuuYpaStORtbLEggQMGOYxzYacMiDUpbfifBgThEzcMgFnvyMaskalQ0WUcQv08aByizug1I00Wcq3XHll',
  );

  /// Where to attach IDs
  /// - 'header' → X-Owner-Project-Id / X-Project-Id headers
  /// - 'query'  → ?ownerProjectLinkId=...&projectId=...

  static const ownerAttachMode = String.fromEnvironment(
    'OWNER_ATTACH_MODE',
    defaultValue: 'header',
  );

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

  /// Default headers for multi-tenant endpoints (users/business)
  static Map<String, String> tenantHeaders({Map<String, String>? extra}) {
    if (ownerAttachMode == 'header') {
      final ownerId = requiredVar(ownerProjectLinkId, 'OWNER_PROJECT_LINK_ID');
      return {
        'Content-Type': 'application/json',
        'X-Owner-Project-Id': ownerId,
        if (extra != null) ...extra,
      };
    }
    // if query-mode or off →
    return {'Content-Type': 'application/json', if (extra != null) ...extra};
  }

  /// Default headers for catalog (Category / ItemType)
  static Map<String, String> projectHeaders({Map<String, String>? extra}) {
    if (ownerAttachMode == 'header') {
      final pid = requiredVar(projectId, 'PROJECT_ID');
      return {
        'Content-Type': 'application/json',
        'X-Project-Id': pid, 
        if (extra != null) ...extra,
      };
    }
    return {'Content-Type': 'application/json', if (extra != null) ...extra};
  }

  /// WS URL 
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

  // Convenience endpoints
  static String get locationIqAutocomplete =>
      'https://api.locationiq.com/v1/autocomplete?key=$locationIqKey';
  static String get locationIqSearch =>
      'https://api.locationiq.com/v1/search?key=$locationIqKey';
  static String get locationIqReverse =>
      'https://us1.locationiq.com/v1/reverse?key=$locationIqKey';
}
