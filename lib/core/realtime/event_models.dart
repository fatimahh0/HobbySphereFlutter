// Flutter 3.35.x
// event_models.dart — strongly-typed event model + safe JSON helpers.

enum Domain {
  // activities & bookings
  activity, // activity domain
  booking, // booking domain
  profile, // profile changes
  notification, // notifications
  user, // user domain (generic)
  review, // reviews
  analytics, // analytics
  // social
  post, // posts
  comment, // comments
  like, // likes
  // chat + friendships
  chat, // conversation
  message, // message (in conversation)
  friendship, // friendship events
}

// action types sent by server
enum ActionType {
  created, // new resource created
  updated, // resource updated/partial patch
  deleted, // resource deleted
  reopened, // resource reopened
  statusChanged, // status changed (custom)
}

// ------- string → enum converters with safe defaults -------

Domain _domainFrom(String s) {
  // normalize to lowercase
  switch (s.toLowerCase()) {
    case 'activity':
      return Domain.activity;
    case 'booking':
      return Domain.booking;
    case 'profile':
      return Domain.profile;
    case 'notification':
      return Domain.notification;
    case 'user':
      return Domain.user;
    case 'review':
      return Domain.review;
    case 'analytics':
      return Domain.analytics;
    case 'post':
      return Domain.post;
    case 'comment':
      return Domain.comment;
    case 'like':
      return Domain.like;
    case 'chat':
      return Domain.chat;
    case 'message':
      return Domain.message;
    case 'friendship':
      return Domain.friendship;
    default:
      return Domain.activity; // safe default
  }
}

ActionType _actionFrom(String s) {
  // normalize to lowercase (and accept "statusChanged" or "statuschanged")
  switch (s.toLowerCase()) {
    case 'created':
      return ActionType.created;
    case 'updated':
      return ActionType.updated;
    case 'deleted':
      return ActionType.deleted;
    case 'reopened':
      return ActionType.reopened;
    case 'statuschanged':
      return ActionType.statusChanged;
    default:
      return ActionType.updated; // safe default
  }
}

// ------- small safe-read helpers for dynamic JSON -------

int _readInt(dynamic v) {
  // accept int directly
  if (v is int) return v; // already int
  // accept string numbers "123"
  if (v is String) return int.tryParse(v) ?? 0; // parse or 0
  // otherwise 0
  return 0; // fallback
}

Map<String, dynamic>? _readMap(dynamic v) {
  // if already a proper map of <String, dynamic>
  if (v is Map<String, dynamic>) return v; // ok
  // if it's Map<dynamic, dynamic> — cast safely
  if (v is Map) {
    // cast each key/value to String,dynamic
    return v.map((k, val) => MapEntry(k.toString(), val)); // toString on keys
  }
  // otherwise null
  return null; // not a map
}

// ------- main event class -------

class RealtimeEvent {
  // server-generated unique id
  final String eventId; // unique event id
  // domain + action
  final Domain domain; // domain enum
  final ActionType action; // action enum
  // ids
  final int businessId; // business scope id
  final int resourceId; // main resource id
  // optional
  final int? version; // optional version
  final DateTime? ts; // timestamp
  final Map<String, dynamic>? data; // payload (typed per domain)

  // ctor
  RealtimeEvent({
    required this.eventId, // id
    required this.domain, // domain
    required this.action, // action
    required this.businessId, // biz id
    required this.resourceId, // resource id
    this.version, // optional version
    this.ts, // optional timestamp
    this.data, // optional map
  });

  // build from raw JSON map
  factory RealtimeEvent.fromJson(Map<String, dynamic> m) {
    // read event id as string
    final id = (m['eventId'] ?? '').toString(); // id to string
    // domain/action strings
    final domStr = (m['domain'] ?? '').toString(); // domain string
    final actStr = (m['action'] ?? '').toString(); // action string
    // ids accept int or string
    final bizId = _readInt(m['businessId']); // business id
    final resId = _readInt(m['resourceId']); // resource id
    // version can be int or string
    final ver = (m['version'] == null)
        ? null
        : _readInt(m['version']); // version
    // ts can be ISO string
    final ts = (m['ts'] is String)
        ? DateTime.tryParse(m['ts'])
        : null; // timestamp
    // data should be a map (accept any map)
    final data = _readMap(m['data']); // payload

    // return final instance
    return RealtimeEvent(
      eventId: id, // set id
      domain: _domainFrom(domStr), // enum domain
      action: _actionFrom(actStr), // enum action
      businessId: bizId, // set biz id
      resourceId: resId, // set res id
      version: ver, // set version
      ts: ts, // set timestamp
      data: data, // set payload
    );
  }
}
