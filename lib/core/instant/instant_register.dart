// Flutter 3.35.x
// Registers "Instant" loaders (user + business).
// Call InstantRegister.init() once in main() AFTER Dio/token are ready.

import 'package:flutter/widgets.dart'; // BuildContext (type only)
import 'package:hobby_sphere/core/instant/instant_manager.dart'; // Instant
import 'package:hobby_sphere/core/network/globals.dart' as g; // global Dio

class InstantRegister {
  // Initialize registry for all important tabs/screens.
  static void init() {
    // ===== USER: HOME =====
    Instant.register(
      name: 'user.home', // unique name
      diskKey: 'ih_user_home', // disk key
      ttlSeconds: 30, // RAM TTL (seconds)
      loader: (ctx) async {
        if (g.appDio == null) return {};
        // Fetch in parallel: feed + counts + lookups.
        final r = await Future.wait([
          g.appDio!.get('/api/items/feed?page=1&limit=12'),
          g.appDio!.get('/api/chat/unread-count'),
          g.appDio!.get('/api/notifications/count'),
          g.appDio!.get('/api/item-type'),
          g.appDio!.get('/api/currencies'),
        ]);

        // Safe extracts
        final items = (r[0].data['items'] as List?) ?? const <dynamic>[];
        final unread = (r[1].data['count'] as int?) ?? 0;
        final notif = (r[2].data['count'] as int?) ?? 0;
        final types = (r[3].data as List?) ?? const <dynamic>[];
        final currs = (r[4].data as List?) ?? const <dynamic>[];

        // Collect thumbnails for precache (optional).
        final thumbs = <String>[];
        for (final it in items.take(8)) {
          final map = it is Map ? it : null;
          final url = map?['thumbnailUrl'] as String?;
          if (url != null && url.isNotEmpty) thumbs.add(url);
        }

        return {
          'feed': items,
          'unread': unread,
          'notif': notif,
          'types': types,
          'curr': currs,
          'thumbs': thumbs,
        };
      },
    );

    // ===== USER: EXPLORE =====
    Instant.register(
      name: 'user.explore',
      diskKey: 'ih_user_explore',
      ttlSeconds: 60,
      loader: (_) async {
        if (g.appDio == null) return {};
        final r = await g.appDio!.get('/api/items/explore?page=1&limit=12');
        final items = (r.data['items'] as List?) ?? const <dynamic>[];
        final thumbs = <String>[];
        for (final it in items.take(8)) {
          final map = it is Map ? it : null;
          final url = map?['thumbnailUrl'] as String?;
          if (url != null && url.isNotEmpty) thumbs.add(url);
        }
        return {'items': items, 'thumbs': thumbs};
      },
    );

    // ===== USER: COMMUNITY =====
    Instant.register(
      name: 'user.community',
      diskKey: 'ih_user_community',
      ttlSeconds: 45,
      loader: (_) async {
        if (g.appDio == null) return {};
        final r = await g.appDio!.get('/api/community/feed?page=1&limit=12');
        return {
          'posts': (r.data['items'] as List?) ?? const <dynamic>[],
          'thumbs': const <String>[], // add if you have images
        };
      },
    );

    // ===== USER: TICKETS =====
    Instant.register(
      name: 'user.tickets',
      diskKey: 'ih_user_tickets',
      ttlSeconds: 45,
      loader: (_) async {
        if (g.appDio == null) return {};
        final r = await g.appDio!.get('/api/bookings/my?status=pending');
        return {
          'pending': (r.data['items'] as List?) ?? const <dynamic>[],
          'thumbs': const <String>[],
        };
      },
    );

    // ===== USER: PROFILE =====
    Instant.register(
      name: 'user.profile',
      diskKey: 'ih_user_profile',
      ttlSeconds: 300,
      loader: (_) async {
        if (g.appDio == null) return {};
        final r = await g.appDio!.get('/api/profile/me');
        return {
          'me': (r.data as Map<String, dynamic>?) ?? <String, dynamic>{},
          'thumbs': const <String>[],
        };
      },
    );

    // ===== BUSINESS: HOME =====
    Instant.register(
      name: 'biz.home',
      diskKey: 'ih_biz_home',
      ttlSeconds: 30,
      loader: (ctx) async {
        if (g.appDio == null) return {};
        final r = await Future.wait([
          g.appDio!.get('/api/business/activities/next?limit=8'),
          g.appDio!.get('/api/business/kpis'),
        ]);

        final items = (r[0].data['items'] as List?) ?? const <dynamic>[];
        final kpis = (r[1].data as Map?) ?? <String, dynamic>{};

        final thumbs = <String>[];
        for (final it in items.take(6)) {
          final map = it is Map ? it : null;
          final url = map?['thumbnailUrl'] as String?;
          if (url != null && url.isNotEmpty) thumbs.add(url);
        }

        return {'next': items, 'kpis': kpis, 'thumbs': thumbs};
      },
    );

    // ===== BUSINESS: BOOKINGS =====
    Instant.register(
      name: 'biz.bookings',
      diskKey: 'ih_biz_bookings',
      ttlSeconds: 45,
      loader: (_) async {
        if (g.appDio == null) return {};
        final r = await g.appDio!.get('/api/business/bookings?status=pending');
        return {
          'pending': (r.data['items'] as List?) ?? const <dynamic>[],
          'thumbs': const <String>[],
        };
      },
    );

    // ===== BUSINESS: ANALYTICS =====
    Instant.register(
      name: 'biz.analytics',
      diskKey: 'ih_biz_analytics',
      ttlSeconds: 90,
      loader: (_) async {
        if (g.appDio == null) return {};
        final r = await g.appDio!.get('/api/business/analytics/overview');
        return {
          'overview': (r.data as Map<String, dynamic>?) ?? <String, dynamic>{},
          'thumbs': const <String>[],
        };
      },
    );

    // ===== BUSINESS: ACTIVITIES LIST =====
    Instant.register(
      name: 'biz.activities',
      diskKey: 'ih_biz_activities',
      ttlSeconds: 60,
      loader: (_) async {
        if (g.appDio == null) return {};
        final r = await g.appDio!.get(
          '/api/business/activities?page=1&limit=12',
        );
        final items = (r.data['items'] as List?) ?? const <dynamic>[];
        final thumbs = <String>[];
        for (final it in items.take(8)) {
          final map = it is Map ? it : null;
          final url = map?['thumbnailUrl'] as String?;
          if (url != null && url.isNotEmpty) thumbs.add(url);
        }
        return {'items': items, 'thumbs': thumbs};
      },
    );
  }
}
