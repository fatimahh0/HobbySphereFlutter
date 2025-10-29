// lib/core/network/interceptors/owner_injector.dart
import 'package:dio/dio.dart';
import 'package:hobby_sphere/config/env.dart';

/// Unified multi-tenant injector:
/// - For `/auth/**` endpoints with a body → inject tenant keys (owner/project) INSIDE the body
/// - For others → inject in header or query (Env.ownerAttachMode: 'header' | 'query' | 'off')
/// - Per-request overrides via Options.extra:
///     extra: {
///       'tenant': 'off' | 'header' | 'query' | 'body',    // override mode
///       'tenantOwnerId': '456',                           // override owner id
///       'tenantProjectId': '123',                         // override project id
///     }
/// - Skips known public/third-party endpoints automatically.
class OwnerInjector extends Interceptor {
  static const _kTenantMode = 'tenant';
  static const _kOwner = 'tenantOwnerId';
  static const _kProject = 'tenantProjectId';

  // Anything that should never get tenant params (health, public, themes, 3rd-party)
  static final _skipPatterns = <RegExp>[
    RegExp(r'(^|/)(actuator|health)(/|$)'),
    RegExp(r'(^|/)public(/|$)'), // /api/public/**
    RegExp(r'(^|/)themes(/|$)'), // /api/themes/**
    RegExp(r'(^|/)docs(/|$)'),
    RegExp(r'(^|/)swagger-ui(/|$)'),
  ];

  bool _isAuthPath(String path) {
    final p = path.startsWith('/') ? path : '/$path';
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

  bool _shouldSkip(String path, String? baseUrl) {
    // Skip if absolute URL to a non-backend host (e.g., LocationIQ, Stripe)
    if (path.startsWith('http://') || path.startsWith('https://')) {
      if (baseUrl != null && baseUrl.isNotEmpty && path.startsWith(baseUrl)) {
        // same host: continue
      } else {
        return true;
      }
    }
    final p = path.startsWith('/') ? path : '/$path';
    return _skipPatterns.any((rx) => rx.hasMatch(p));
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      // 0) Skip public/3rd-party routes
      if (_shouldSkip(options.path, options.baseUrl)) {
        return handler.next(options);
      }

      // 1) Resolve mode: per-request override > global
      final overrideMode = options.extra[_kTenantMode]
          ?.toString()
          .toLowerCase()
          .trim();
      final globalMode = Env.ownerAttachMode
          .toLowerCase()
          .trim(); // 'header' | 'query' | 'off'
      final mode = (overrideMode?.isNotEmpty ?? false)
          ? overrideMode!
          : globalMode;

      // 2) Resolve owner/project ids (override > Env)
      final overrideOwner = options.extra[_kOwner]?.toString().trim();
      final overrideProject = options.extra[_kProject]?.toString().trim();
      final ownerId = (overrideOwner?.isNotEmpty ?? false)
          ? overrideOwner!
          : Env.ownerProjectLinkId.trim();
      final projectId = (overrideProject?.isNotEmpty ?? false)
          ? overrideProject!
          : Env.projectId.trim();

      // 3) Nothing to inject?
      final hasOwner = ownerId.isNotEmpty;
      final hasProject = projectId.isNotEmpty;
      if (mode == 'off' || (!hasOwner && !hasProject)) {
        return handler.next(options);
      }

      final isAuth = _isAuthPath(options.path);
      final hasBody = _methodHasBody(options.method);

      // Helper to upsert keys in a JSON-like body
      void _injectIntoBody() {
        if (!hasBody) return;
        if (options.data == null) options.data = <String, dynamic>{};

        if (options.data is Map) {
          final map = Map<String, dynamic>.from(options.data as Map);
          if (hasOwner) {
            map.putIfAbsent(
              'ownerProjectLinkId',
              () => int.tryParse(ownerId) ?? ownerId,
            );
          }
          if (hasProject) {
            map.putIfAbsent(
              'projectId',
              () => int.tryParse(projectId) ?? projectId,
            );
          }
          options.data = map;
        } else if (options.data is FormData) {
          final fd = options.data as FormData;
          if (hasOwner &&
              !fd.fields.any((e) => e.key == 'ownerProjectLinkId')) {
            fd.fields.add(MapEntry('ownerProjectLinkId', ownerId));
          }
          if (hasProject && !fd.fields.any((e) => e.key == 'projectId')) {
            fd.fields.add(MapEntry('projectId', projectId));
          }
        } // else non-mergeable → leave, backend will 400 if mandatory
      }

      if (isAuth && hasBody) {
        // AUTH endpoints prefer BODY injection
        _injectIntoBody();
      } else {
        // Non-AUTH: default to header/query/body depending on mode
        if (mode == 'header') {
          if (hasOwner) options.headers['X-Owner-Project-Id'] = ownerId;
          if (hasProject) options.headers['X-Project-Id'] = projectId;
        } else if (mode == 'query') {
          final qp = Map<String, dynamic>.from(options.queryParameters);
          if (hasOwner) qp['ownerProjectLinkId'] = ownerId;
          if (hasProject) qp['projectId'] = projectId;
          options.queryParameters = qp;
        } else if (mode == 'body') {
          _injectIntoBody();
        }
      }

      handler.next(options);
    } catch (_) {
      handler.next(options); // fail-open
    }
  }
}
