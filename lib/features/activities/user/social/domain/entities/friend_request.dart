// 🤝 Friend request list item (used for Received/Sent tabs).
import 'user_min.dart'; // compact user

class FriendRequestItem {
  final int requestId; // request id
  final UserMin user; // other party
  final bool isIncoming; // true if I received

  const FriendRequestItem({
    required this.requestId, // id
    required this.user, // user
    required this.isIncoming, // dir
  });

  factory FriendRequestItem.fromMap(
    Map<String, dynamic> m, {
    required bool incoming, // incoming?
  }) {
    Map<String, dynamic>? u =
        (incoming ? m['sender'] : m['receiver'])
            as Map<String, dynamic>?; // nested
    u ??= m['user'] as Map<String, dynamic>?; // alt
    u ??= m; // fallback (already user)

    final reqId = (m['id'] ?? m['requestId'] ?? 0) as num; // id

    return FriendRequestItem(
      requestId: reqId.toInt(), // int
      user: UserMin.fromMap(u), // map user
      isIncoming: incoming, // flag
    );
  }

@override
  String toString() => 'FriendRequestItem(requestId: $requestId, user: $user, isIncoming: $isIncoming)';
}


  