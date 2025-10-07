// chat_message.dart — Flutter 3.35.x
// Clean, simple, professional. Each line has a short comment.

import 'package:equatable/equatable.dart'; // for == and props (optional)

class ChatMessage extends Equatable {
  final int id; // backend id (0 for local pending)
  final int senderId; // who sent
  final int receiverId; // who received
  final String? text; // message text (optional)
  final String? imageUrl; // remote image url from server (optional)
  final String? localImagePath; // NEW: local file path for instant preview
  final DateTime sentAt; // time sent
  final bool isMine; // true if from me
  final bool isRead; // read flag

  const ChatMessage({
    required this.id, // 0 means local/pending
    required this.senderId, // sender user id
    required this.receiverId, // receiver user id
    required this.sentAt, // timestamp
    required this.isMine, // side
    required this.isRead, // read state
    this.text, // optional text
    this.imageUrl, // optional remote url
    this.localImagePath, // optional local path for preview
  });

  // ---------- helpers (kept simple and defensive) ----------

  static int _intish(dynamic v) {
    // convert anything to int safely
    if (v == null) return 0; // default
    if (v is num) return v.toInt(); // number
    return int.tryParse(v.toString()) ?? 0; // parse string
  }

  static DateTime _parseTs(dynamic v) {
    // parse many timestamp formats
    if (v == null) return DateTime.now(); // fallback now
    if (v is int) {
      // support seconds or millis
      final isMillis = v > 9999999999;
      return DateTime.fromMillisecondsSinceEpoch(isMillis ? v : v * 1000);
    }
    var s = v.toString().trim(); // to string
    // handle "YYYY-MM-DD HH:mm" or with seconds
    final re = RegExp(r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}(:\d{2})?$');
    if (re.hasMatch(s)) {
      if (!s.contains(':', 14)) s = '$s:00'; // ensure seconds
      s = s.replaceFirst(' ', 'T'); // space -> T
    }
    return DateTime.tryParse(s) ?? DateTime.now(); // final parse
  }

  static String? _stringish(dynamic v) {
    // normalize nullable string from many shapes
    if (v == null) return null; // none
    if (v is String) return v.trim().isEmpty ? null : v.trim(); // clean
    if (v is Map) {
      // try common keys
      return _stringish(v['url'] ?? v['path'] ?? v['href'] ?? v['link']);
    }
    return v.toString(); // fallback
  }

  static bool _readish(Map<String, dynamic> m) {
    // read flag from many keys/types
    final read =
        m['read'] ?? m['isRead'] ?? m['seen'] ?? m['isSeen']; // variants
    if (read is bool) return read; // bool
    if (read is num) return read != 0; // number
    if (read is String) return read.toLowerCase() == 'true'; // "true"
    final readAt = m['readAt'] ?? m['seenAt']; // timestamp means read
    return readAt != null; // true if exists
  }

  static String? _pickImage(Map<String, dynamic> m) {
    // try several keys to find an image url
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
    // try several keys to find the text
    return _stringish(m['message'] ?? m['text'] ?? m['body'] ?? m['content']);
  }

  // ---------- factory from backend map (server messages) ----------

  factory ChatMessage.fromMap(Map<String, dynamic> m, int me) {
    // unpack if payload is wrapped under "data" or "message"
    final mm = (m['data'] is Map)
        ? Map<String, dynamic>.from(m['data'] as Map) // use data
        : (m['message'] is Map)
        ? Map<String, dynamic>.from(m['message'] as Map) // use message
        : m; // else use as-is

    // ids (with many possible keys)
    final id = _intish(mm['id'] ?? mm['messageId'] ?? mm['mid']); // message id
    final senderId = _intish(
      mm['senderId'] ?? mm['from'] ?? mm['sender'] ?? mm['fromId'],
    ); // sender
    final receiverId = _intish(
      mm['receiverId'] ?? mm['to'] ?? mm['receiver'] ?? mm['toId'],
    ); // receiver

    // content
    final text = _pickText(mm); // message text
    final image = _pickImage(mm); // remote image url

    // timestamp from many keys
    final ts =
        mm['sentAt'] ??
        mm['createdAt'] ??
        mm['timestamp'] ??
        mm['time'] ??
        mm['date']; // raw time

    // read state
    final isRead = _readish(mm); // seen?

    // "mine" can be provided; else compute by sender == me
    final mineRaw = mm['mine']; // raw value
    final isMine = (mineRaw is bool)
        ? mineRaw // already bool
        : (mineRaw is String)
        ? mineRaw.toLowerCase() ==
              'true' // "true"/"false"
        : senderId == me; // fallback

    // IMPORTANT: messages from backend never carry localImagePath
    // so we set localImagePath = null here.
    return ChatMessage(
      id: id, // server id
      senderId: senderId, // sender
      receiverId: receiverId, // receiver
      text: text, // optional text
      imageUrl: image, // optional remote image
      localImagePath: null, // no local path from server
      sentAt: _parseTs(ts), // parse time
      isMine: isMine, // side
      isRead: isRead, // read
    );
  }

  // ---------- convenience factory for local pending image message ----------

  factory ChatMessage.pendingLocalImage({
    required int me, // my user id
    required int peerId, // other user id
    required String filePath, // local file path from picker
  }) {
    return ChatMessage(
      id: 0, // 0 means not saved on server yet
      senderId: me, // me
      receiverId: peerId, // peer
      text: null, // image only
      imageUrl: null, // no remote url yet
      localImagePath: filePath, // show instant preview
      sentAt: DateTime.now(), // now
      isMine: true, // my side
      isRead: false, // not read
    );
  }

  // ---------- copyWith for updates (e.g., after upload finishes) ----------

  ChatMessage copyWith({
    int? id, // new id (server)
    int? senderId, // new sender
    int? receiverId, // new receiver
    String? text, // new text
    String? imageUrl, // new remote url
    String? localImagePath, // new local path (often set to null after upload)
    DateTime? sentAt, // new time
    bool? isMine, // new side
    bool? isRead, // new read
  }) {
    return ChatMessage(
      id: id ?? this.id, // keep old if null
      senderId: senderId ?? this.senderId, // keep old
      receiverId: receiverId ?? this.receiverId, // keep old
      text: text ?? this.text, // keep old
      imageUrl: imageUrl ?? this.imageUrl, // keep old
      localImagePath: localImagePath ?? this.localImagePath, // keep old
      sentAt: sentAt ?? this.sentAt, // keep old
      isMine: isMine ?? this.isMine, // keep old
      isRead: isRead ?? this.isRead, // keep old
    );
  }

  // ---------- equatable props (nice for Bloc state diffs) ----------

  @override
  List<Object?> get props => [
    id, // id
    senderId, // sender
    receiverId, // receiver
    text, // text
    imageUrl, // remote url
    localImagePath, // local path
    sentAt, // time
    isMine, // side
    isRead, // read
  ];
}
