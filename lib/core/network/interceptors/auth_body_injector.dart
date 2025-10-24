// lib/core/network/interceptors/owner_injector.dart
import 'package:dio/dio.dart';
import 'package:hobby_sphere/config/env.dart';

/// Injects ownerProjectLinkId universally:
/// - /auth/**  => inject into BODY (Map or FormData) for methods with a body
/// - others    => header (default) or query, controlled by Env.ownerAttachMode
///
/// Per-request override via Options.extra:
///   extra: {
///     'tenant': 'off' | 'header' | 'query' | 'body',  // optional
///     'tenantOwnerId': '456',                         // optional override ID
///   }
class OwnerInjector extends Interceptor {
  static const _kTenantMode = 'tenant';
  static const _kTenantOwner = 'tenantOwnerId';

  bool _isAuthPath(String path) {
    final p = path.startsWith('/') ? path : '/$path';
    // match .../auth/... regardless of prefix (/api, /v1, etc.)
    return RegExp(r'(^|/)auth(/|$)').hasMatch(p);
  }

  bool _methodHasBody(String method) {
    switch (method.toUpperCase()) {
      case 'POST':
      case 'PUT':
      case 'PATCH':
      case 'DELETE':
        return true;
      default:
        return false;
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      // Resolve mode: per-request override > global
      final override = options.extra[_kTenantMode]
          ?.toString()
          .toLowerCase()
          .trim();
      final globalMode = Env.ownerAttachMode
          .toLowerCase()
          .trim(); // 'header' | 'query' | 'off'
      final mode = override?.isNotEmpty == true ? override! : globalMode;

      // Resolve owner id: per-request override > Env
      final overrideId = options.extra[_kTenantOwner]?.toString().trim();
      final ownerId = (overrideId?.isNotEmpty == true
          ? overrideId!
          : Env.ownerProjectLinkId.trim());

      // If no owner or mode off → pass through
      if (!Env.hasOwner || ownerId.isEmpty || mode == 'off') {
        return handler.next(options);
      }

      final isAuth = _isAuthPath(options.path);
      final hasBody = _methodHasBody(options.method);

      if (isAuth && hasBody) {
        // AUTH endpoints → inject inside BODY
        if (options.data == null) options.data = <String, dynamic>{};

        if (options.data is Map) {
          final map = Map<String, dynamic>.from(options.data as Map);
          map.putIfAbsent(
            'ownerProjectLinkId',
            () => int.tryParse(ownerId) ?? ownerId,
          );
          options.data = map;
        } else if (options.data is FormData) {
          final fd = options.data as FormData;
          final hasField = fd.fields.any((e) => e.key == 'ownerProjectLinkId');
          if (!hasField) {
            fd.fields.add(MapEntry('ownerProjectLinkId', ownerId));
          }
          // leave files as-is
        } // else: non-mergeable body → fail-open; backend سيعيد 400 إذا ناقص
      } else {
        // NON-AUTH or methods without body → header or query
        if (mode == 'header') {
          options.headers['X-Owner-Project-Id'] = ownerId;
        } else if (mode == 'query') {
          options.queryParameters = {
            ...options.queryParameters,
            'ownerProjectLinkId': ownerId,
          };
        } else if (mode == 'body' && hasBody) {
          // optional extra mode: force body even for non-auth
          if (options.data == null) options.data = <String, dynamic>{};
          if (options.data is Map) {
            final map = Map<String, dynamic>.from(options.data as Map);
            map.putIfAbsent(
              'ownerProjectLinkId',
              () => int.tryParse(ownerId) ?? ownerId,
            );
            options.data = map;
          } else if (options.data is FormData) {
            final fd = options.data as FormData;
            final hasField = fd.fields.any(
              (e) => e.key == 'ownerProjectLinkId',
            );
            if (!hasField)
              fd.fields.add(MapEntry('ownerProjectLinkId', ownerId));
          }
        }
      }

      handler.next(options);
    } catch (_) {
      handler.next(options); // fail-open
    }
  }
}
