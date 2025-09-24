// One chat message bubble (text or image).
class ChatMessage {
  final int id; // message id
  final int senderId; // sender user id
  final int receiverId; // receiver user id
  final String? text; // optional text
  final String? imageUrl; // optional image
  final DateTime sentAt; // timestamp
  final bool isMine; // true if current user sent it
  final bool isRead; // read flag

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.sentAt,
    required this.isMine,
    required this.isRead,
    this.text,
    this.imageUrl,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> m, int me) => ChatMessage(
    id: (m['id'] as num).toInt(),
    senderId: (m['senderId'] as num).toInt(),
    receiverId: (m['receiverId'] as num).toInt(),
    text: m['message']?.toString(),
    imageUrl: m['imageUrl']?.toString(),
    sentAt: DateTime.tryParse(m['sentAt']?.toString() ?? '') ?? DateTime.now(),
    isMine: (m['senderId'] as num).toInt() == me,
    isRead: (m['read'] ?? m['isRead'] ?? false) == true,
  );
}
