// ===== Flutter 3.35.x =====
// One event model for all realtime updates across the app.

/// domain of the event (which area changed)
enum Domain {
  activity, // activities CRUD / reopen / status
  booking, // bookings create / status
  profile, // business profile updates
  notification, // business notifications
  user, // business users
  review, // business reviews
  analytics, // ✅ analytics snapshot/pulse from backend (NEW)
}

/// type of change
enum ActionType {
  created, // new item created
  updated, // item updated
  deleted, // item deleted
  reopened, // item reopened
  statusChanged, // item status changed
}

/// small helper to parse domain from string sent by server
Domain _domainFrom(String s) {
  switch (s.toLowerCase()) {
    case 'activity':
      return Domain.activity; // "activity"
    case 'booking':
      return Domain.booking; // "booking"
    case 'profile':
      return Domain.profile; // "profile"
    case 'notification':
      return Domain.notification; // "notification"
    case 'user':
      return Domain.user; // "user"
    case 'review':
      return Domain.review; // "review"
    case 'analytics':
      return Domain.analytics; // ✅ "analytics" (NEW)
  }
  return Domain.activity; // fallback
}

/// small helper to parse action from string
ActionType _actionFrom(String s) {
  switch (s.toLowerCase()) {
    case 'created':
      return ActionType.created; // "created"
    case 'updated':
      return ActionType.updated; // "updated"
    case 'deleted':
      return ActionType.deleted; // "deleted"
    case 'reopened':
      return ActionType.reopened; // "reopened"
    case 'statuschanged':
      return ActionType.statusChanged; // "statusChanged"
  }
  return ActionType.updated; // fallback
}

/// the realtime event object we use across the app
class RealtimeEvent {
  final String eventId; // unique id for dedupe
  final Domain domain; // which domain changed
  final ActionType action; // what happened
  final int businessId; // which business is affected
  final int resourceId; // which entity id changed
  final int? version; // optional: ordering
  final DateTime? ts; // optional: server timestamp
  final Map<String, dynamic>? data; // optional: extra payload

  RealtimeEvent({
    required this.eventId, // set id
    required this.domain, // set domain
    required this.action, // set action
    required this.businessId, // set business id
    required this.resourceId, // set resource id
    this.version, // optional
    this.ts, // optional
    this.data, // optional
  });

  /// build from JSON (from WebSocket message)
  factory RealtimeEvent.fromJson(Map<String, dynamic> m) {
    return RealtimeEvent(
      eventId: (m['eventId'] ?? '').toString(), // read id
      domain: _domainFrom((m['domain'] ?? '').toString()), // read domain
      action: _actionFrom((m['action'] ?? '').toString()), // read action
      businessId: (m['businessId'] ?? 0) as int, // biz id
      resourceId: (m['resourceId'] ?? 0) as int, // entity id
      version: (m['version'] is int) ? m['version'] as int : null, // version
      ts: (m['ts'] is String) ? DateTime.tryParse(m['ts']) : null, // timestamp
      data: (m['data'] is Map<String, dynamic>)
          ? (m['data'] as Map<String, dynamic>) // payload
          : null,
    );
  }
}
