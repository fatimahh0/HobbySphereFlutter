// Friend request item used in "Received" / "Sent" lists.
import 'package:hobby_sphere/features/activities/user/social/domain/entities/user_min.dart';

class FriendRequestItem {
  final int requestId; // request id (needed to accept/reject)
  final UserMin user; // other party compact user
  final bool isIncoming; // true if you received it

  const FriendRequestItem({
    required this.requestId,
    required this.user,
    required this.isIncoming,
  });

  // Build from map; backend can return different shapes,
  // so we handle both common cases (Friendship or DTO).
  factory FriendRequestItem.fromMap(
    Map<String, dynamic> m, {
    required bool incoming,
  }) {
    // try to find nested 'sender'/'receiver' user
    Map<String, dynamic>? u =
        (incoming ? m['sender'] : m['receiver']) as Map<String, dynamic>?;
    // or flat user fields like your /users/all
    u ??= m['user'] as Map<String, dynamic>?;
    // fallback: whole object is a user (if repo pre-flattened)
    u ??= m;

    final reqId = (m['id'] ?? m['requestId'] ?? 0) as num;

    return FriendRequestItem(
      requestId: reqId.toInt(),
      user: UserMin.fromMap(u),
      isIncoming: incoming,
    );
  }
}
