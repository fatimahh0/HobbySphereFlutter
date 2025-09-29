// Router: listen to global bus and fan-out to feature listeners.
import 'dart:async';
import 'event_models.dart';
import 'realtime_bus.dart';

typedef Remover = void Function();

class UserRealtimeBridge {
  StreamSubscription? _sub;

  // legacy single listeners (kept for community feed you already wired)
  void Function(Map<String, dynamic> payload)? onNotification;
  void Function(Map<String, dynamic> payload)? onBooking;
  void Function(Map<String, dynamic> fullPost)? onPostCreated;
  void Function(int postId, Map<String, dynamic> patch)? onPostUpdated;
  void Function(int postId)? onPostDeleted;
  void Function(int postId, Map<String, dynamic> fullComment)? onCommentAdded;
  void Function(int postId, int commentId)? onCommentDeleted;
  void Function(int postId, bool liked)? onLikeChanged;
  void Function(Map<String, dynamic> fullActivity)? onActivityCreated;
  void Function(int activityId, Map<String, dynamic> patch)? onActivityUpdated;
  void Function(int activityId)? onActivityDeleted;

  // NEW multicast sets — multiple screens can subscribe safely.
  final _onNotification = <void Function(Map<String, dynamic>)>{};

  // chat / conversations
  final _onConversationCreated = <void Function(Map<String, dynamic>)>{};
  final _onConversationUpdated = <void Function(int, Map<String, dynamic>)>{};
  final _onConversationDeleted = <void Function(int)>{};

  // messages
  final _onMessageCreated =
      <void Function(int /*convId*/, Map<String, dynamic>)>{};
  final _onMessageUpdated = <void Function(int, int, Map<String, dynamic>)>{};
  final _onMessageDeleted = <void Function(int, int)>{};
  final _onMessageSignal = <void Function(int, Map<String, dynamic>)>{};

  // friendships
  final _onFriendshipCreated = <void Function(Map<String, dynamic>)>{};
  final _onFriendshipUpdated = <void Function(Map<String, dynamic>)>{};
  final _onFriendshipDeleted = <void Function(Map<String, dynamic>)>{};

  void start() => _sub ??= RealtimeBus.I.stream.listen(_handle);
  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
  }

  // subscribe helpers
  Remover onNotificationListen(void Function(Map<String, dynamic>) cb) {
    _onNotification.add(cb);
    return () => _onNotification.remove(cb);
  }

  Remover onConversationCreatedListen(void Function(Map<String, dynamic>) cb) {
    _onConversationCreated.add(cb);
    return () => _onConversationCreated.remove(cb);
  }

  Remover onConversationUpdatedListen(
    void Function(int, Map<String, dynamic>) cb,
  ) {
    _onConversationUpdated.add(cb);
    return () => _onConversationUpdated.remove(cb);
  }

  Remover onConversationDeletedListen(void Function(int) cb) {
    _onConversationDeleted.add(cb);
    return () => _onConversationDeleted.remove(cb);
  }

  Remover onMessageCreatedListen(void Function(int, Map<String, dynamic>) cb) {
    _onMessageCreated.add(cb);
    return () => _onMessageCreated.remove(cb);
  }

  Remover onMessageUpdatedListen(
    void Function(int, int, Map<String, dynamic>) cb,
  ) {
    _onMessageUpdated.add(cb);
    return () => _onMessageUpdated.remove(cb);
  }

  Remover onMessageDeletedListen(void Function(int, int) cb) {
    _onMessageDeleted.add(cb);
    return () => _onMessageDeleted.remove(cb);
  }

  Remover onMessageSignalListen(void Function(int, Map<String, dynamic>) cb) {
    _onMessageSignal.add(cb);
    return () => _onMessageSignal.remove(cb);
  }

  Remover onFriendshipCreatedListen(void Function(Map<String, dynamic>) cb) {
    _onFriendshipCreated.add(cb);
    return () => _onFriendshipCreated.remove(cb);
  }

  Remover onFriendshipUpdatedListen(void Function(Map<String, dynamic>) cb) {
    _onFriendshipUpdated.add(cb);
    return () => _onFriendshipUpdated.remove(cb);
  }

  Remover onFriendshipDeletedListen(void Function(Map<String, dynamic>) cb) {
    _onFriendshipDeleted.add(cb);
    return () => _onFriendshipDeleted.remove(cb);
  }

  void _handle(RealtimeEvent e) {
    switch (e.domain) {
      case Domain.notification:
        for (final f in _onNotification) f(e.data ?? const {});
        onNotification?.call(e.data ?? const {});
        break;

      case Domain.booking:
        onBooking?.call(e.data ?? const {});
        break;

      case Domain.post:
        switch (e.action) {
          case ActionType.created:
            final full = (e.data?['post'] as Map?)?.cast<String, dynamic>();
            if (full != null) onPostCreated?.call(full);
            break;
          case ActionType.updated:
            final id = e.data?['postId'] as int?;
            final patch = (e.data?['changes'] as Map?)?.cast<String, dynamic>();
            if (id != null && patch != null) onPostUpdated?.call(id, patch);
            break;
          case ActionType.deleted:
            final id = e.data?['postId'] as int?;
            if (id != null) onPostDeleted?.call(id);
            break;
          default:
            break;
        }
        break;

      case Domain.comment:
        if (e.action == ActionType.created) {
          final pid = e.data?['postId'] as int?;
          final full = (e.data?['comment'] as Map?)?.cast<String, dynamic>();
          if (pid != null && full != null) onCommentAdded?.call(pid, full);
        } else if (e.action == ActionType.deleted) {
          final pid = e.data?['postId'] as int?;
          final cid = e.data?['commentId'] as int?;
          if (pid != null && cid != null) onCommentDeleted?.call(pid, cid);
        }
        break;

      case Domain.like:
        final pid = e.data?['postId'] as int?;
        final liked = e.data?['liked'] == true;
        if (pid != null) onLikeChanged?.call(pid, liked);
        break;

      case Domain.activity:
        switch (e.action) {
          case ActionType.created:
            final full = (e.data?['activity'] as Map?)?.cast<String, dynamic>();
            if (full != null) onActivityCreated?.call(full);
            break;
          case ActionType.updated:
          case ActionType.reopened:
          case ActionType.statusChanged:
            final id = e.data?['activityId'] as int?;
            final patch = (e.data?['changes'] as Map?)?.cast<String, dynamic>();
            if (id != null && patch != null) onActivityUpdated?.call(id, patch);
            break;
          case ActionType.deleted:
            final id = e.data?['activityId'] as int?;
            if (id != null) onActivityDeleted?.call(id);
            break;
        }
        break;

      // ===== NEW: Chat/Message/Friendship =====
      case Domain.chat:
        switch (e.action) {
          case ActionType.created:
            final conv = (e.data?['conversation'] as Map?)
                ?.cast<String, dynamic>();
            if (conv != null) for (final f in _onConversationCreated) f(conv);
            break;
          case ActionType.updated:
            final id = e.data?['conversationId'] as int?;
            final patch = (e.data?['changes'] as Map?)?.cast<String, dynamic>();
            if (id != null && patch != null) {
              for (final f in _onConversationUpdated) f(id, patch);
            }
            break;
          case ActionType.deleted:
            final id = e.data?['conversationId'] as int?;
            if (id != null) for (final f in _onConversationDeleted) f(id);
            break;
          default:
            break;
        }
        break;

      case Domain.message:
        switch (e.action) {
          case ActionType.created:
            final cid = e.data?['conversationId'] as int?;
            final msg = (e.data?['message'] as Map?)?.cast<String, dynamic>();
            if (cid != null && msg != null) {
              for (final f in _onMessageCreated) f(cid, msg);
            }
            break;
          case ActionType.updated:
            final cid = e.data?['conversationId'] as int?;
            final mid = e.data?['messageId'] as int?;
            final chg = (e.data?['changes'] as Map?)?.cast<String, dynamic>();
            if (cid != null && mid != null && chg != null) {
              for (final f in _onMessageUpdated) f(cid, mid, chg);
            }
            final signal = (e.data?['signal'] as Map?)?.cast<String, dynamic>();
            if (cid != null && signal != null) {
              for (final f in _onMessageSignal) f(cid, signal);
            }
            break;
          case ActionType.deleted:
            final cid = e.data?['conversationId'] as int?;
            final mid = e.data?['messageId'] as int?;
            if (cid != null && mid != null) {
              for (final f in _onMessageDeleted) f(cid, mid);
            }
            break;
          default:
            break;
        }
        break;

      case Domain.friendship:
        switch (e.action) {
          case ActionType.created:
            for (final f in _onFriendshipCreated) f(e.data ?? const {});
            break;
          case ActionType.updated:
            for (final f in _onFriendshipUpdated) f(e.data ?? const {});
            break;
          case ActionType.deleted:
            for (final f in _onFriendshipDeleted) f(e.data ?? const {});
            break;
          default:
            break;
        }
        break;

      default:
        break;
    }
  }
}
