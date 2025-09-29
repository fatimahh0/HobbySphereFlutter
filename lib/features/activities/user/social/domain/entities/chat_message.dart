// chat_message.dart (only the factory + helpers need updating)
class ChatMessage {
  final int id;
  final int senderId;
  final int receiverId;
  final String? text;
  final String? imageUrl;
  final DateTime sentAt;
  final bool isMine;
  final bool isRead;

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

  static int _intish(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static DateTime _parseTs(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is int) {
      final isMillis = v > 9999999999;
      return DateTime.fromMillisecondsSinceEpoch(isMillis ? v : v * 1000);
    }
    var s = v.toString().trim();
    // Accept "2025-08-09 13:48" → turn into ISO-ish
    final re = RegExp(r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}(:\d{2})?$');
    if (re.hasMatch(s)) {
      if (!s.contains(':', 14)) s = '$s:00'; // add seconds if missing
      s = s.replaceFirst(' ', 'T'); // space → T
    }
    return DateTime.tryParse(s) ?? DateTime.now();
  }

  static String? _stringish(dynamic v) {
    if (v == null) return null;
    if (v is String) return v.trim().isEmpty ? null : v.trim();
    if (v is Map) {
      return _stringish(v['url'] ?? v['path'] ?? v['href'] ?? v['link']);
    }
    return v.toString();
  }

  static bool _readish(Map<String, dynamic> m) {
    final read = m['read'] ?? m['isRead'] ?? m['seen'] ?? m['isSeen'];
    if (read is bool) return read;
    if (read is num) return read != 0;
    if (read is String) return read.toLowerCase() == 'true';
    final readAt = m['readAt'] ?? m['seenAt'];
    return readAt != null;
  }

  static String? _pickImage(Map<String, dynamic> m) {
    return _stringish(
      m['imageUrl'] ??
          m['imageURL'] ??
          m['image'] ??
          m['image_path'] ??
          m['imagePath'] ??
          m['photo'] ??
          m['fileUrl'] ??
          m['mediaUrl'] ??
          (m['attachment'] is Map ? (m['attachment'] as Map)['url'] : null),
    );
  }

  static String? _pickText(Map<String, dynamic> m) {
    return _stringish(m['message'] ?? m['text'] ?? m['body'] ?? m['content']);
  }

  factory ChatMessage.fromMap(Map<String, dynamic> m, int me) {
    final mm = (m['data'] is Map)
        ? Map<String, dynamic>.from(m['data'] as Map)
        : (m['message'] is Map)
        ? Map<String, dynamic>.from(m['message'] as Map)
        : m;

    final id = _intish(mm['id'] ?? mm['messageId'] ?? mm['mid']);
    final senderId = _intish(
      mm['senderId'] ?? mm['from'] ?? mm['sender'] ?? mm['fromId'],
    );
    final receiverId = _intish(
      mm['receiverId'] ?? mm['to'] ?? mm['receiver'] ?? mm['toId'],
    );

    final text = _pickText(mm);
    final image = _pickImage(mm);
    final ts =
        mm['sentAt'] ??
        mm['createdAt'] ??
        mm['timestamp'] ??
        mm['time'] ??
        mm['date'];
    final isRead = _readish(mm);

    // Prefer backend-provided "mine" if present; fallback to (senderId == me)
    final mineRaw = mm['mine'];
    final isMine = (mineRaw is bool)
        ? mineRaw
        : (mineRaw is String)
        ? mineRaw.toLowerCase() == 'true'
        : senderId == me;

    return ChatMessage(
      id: id,
      senderId: senderId,
      receiverId: receiverId,
      text: text,
      imageUrl: image,
      sentAt: _parseTs(ts),
      isMine: isMine,
      isRead: isRead,
    );
  }
}
