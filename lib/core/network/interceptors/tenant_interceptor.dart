// lib/core/network/interceptors/tenant_interceptor.dart
import 'package:dio/dio.dart';
import 'package:hobby_sphere/config/env.dart';

/// Per-request overrides via `Options.extra`:
///   - 'tenant': 'off' | 'header' | 'query'
///   - 'tenantOwnerId': '456'   (override ID for this request)
///
/// Default behavior comes from Env.ownerAttachMode.
class TenantInterceptor extends Interceptor {
  static const _keyTenant = 'tenant';
  static const _keyTenantOwnerId = 'tenantOwnerId';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 1) short-circuit if globally off or no owner configured
    final globalMode = Env.ownerAttachMode
        .toLowerCase()
        .trim(); // header|query|off
    final hasOwner = Env.hasOwner;

    // 2) per-request override
    final overrideModeRaw = options.extra[_keyTenant]
        ?.toString()
        .toLowerCase()
        .trim();
    final mode = overrideModeRaw ?? globalMode;

    if (mode == 'off' || !hasOwner) {
      return handler.next(options);
    }

    // 3) resolve owner id (global or per-call)
    final ownerId =
        (options.extra[_keyTenantOwnerId]?.toString().trim().isNotEmpty ??
            false)
        ? options.extra[_keyTenantOwnerId].toString().trim()
        : Env.ownerProjectLinkId.trim();

    if (ownerId.isEmpty) {
      return handler.next(options); // nothing to add
    }

    // 4) attach as header or query param
    if (mode == 'header') {
      options.headers['X-Owner-Project-Id'] = ownerId;
    } else if (mode == 'query') {
      // merge without clobbering existing params
      options.queryParameters = {
        ...options.queryParameters,
        'ownerProjectLinkId': ownerId,
      };
    }

    handler.next(options);
  }
}
