// 💬 ChatBubble — Flutter 3.35.x
// Theme colors only (ColorScheme from AppTheme/AppColors/Palette).
// Local preview with spinner while pending.

import 'dart:io'; // File
import 'package:flutter/material.dart'; // UI
import 'package:hobby_sphere/features/activities/user/social/domain/entities/chat_message.dart'; // entity

class ChatBubble extends StatelessWidget {
  final ChatMessage m; // message
  const ChatBubble({super.key, required this.m}); // ctor

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme; // theme colors
    final bool mine = m.isMine; // side

    final Color bg = mine ? cs.primary : cs.surface; // bubble bg
    final Color fg = mine ? cs.onPrimary : cs.onSurface; // text color
    final Color borderColor = mine
        ? Colors.transparent
        : cs.outlineVariant; // other subtle border

    return Container(
      constraints: const BoxConstraints(maxWidth: 320), // width cap
      padding: EdgeInsets.zero, // child pads
      decoration: BoxDecoration(
        color: bg, // bg
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(14), // round
          topRight: const Radius.circular(14), // round
          bottomLeft: Radius.circular(mine ? 14 : 4), // tail-ish
          bottomRight: Radius.circular(mine ? 4 : 14), // tail-ish
        ),
        border: Border.all(color: borderColor, width: mine ? 0 : 0.8), // thin
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.06), // subtle elevation
            blurRadius: 8, // blur
            offset: const Offset(0, 2), // drop
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: mine
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start, // side
        children: [
          // text
          if ((m.text ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8), // pad
              child: Text(
                m.text!, // body
                style: TextStyle(color: fg, height: 1.25), // readable
              ),
            ),

          // spacing if also image
          if ((m.text ?? '').isNotEmpty &&
              ((m.imageUrl ?? '').isNotEmpty ||
                  (m.localImagePath ?? '').isNotEmpty))
            const SizedBox(height: 6), // gap
          // image (local or remote)
          if ((m.localImagePath ?? '').isNotEmpty ||
              (m.imageUrl ?? '').isNotEmpty)
            _ImagePreview(
              localPath: m.localImagePath, // local
              remoteUrl: m.imageUrl, // remote
              pending:
                  (m.id <= 0) || // temp id
                  (((m.localImagePath ?? '').isNotEmpty) &&
                      ((m.imageUrl ?? '').isEmpty)), // still local only
              radius: BorderRadius.only(
                topLeft: const Radius.circular(12), // shape
                topRight: const Radius.circular(12), // shape
                bottomLeft: Radius.circular(mine ? 12 : 6), // shape
                bottomRight: Radius.circular(mine ? 6 : 12), // shape
              ),
              overlayColor: cs.scrim.withOpacity(0.26), // dim from theme
            ),

          // status (my messages only)
          if (mine)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 8), // pad
              child: _MiniStatus(
                isRead: m.isRead, // read?
                isPending: m.id <= 0, // pending?
                color: cs.onSurfaceVariant, // subtle color
              ),
            ),
        ],
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final String? localPath; // local path
  final String? remoteUrl; // remote url
  final bool pending; // uploading?
  final BorderRadius radius; // shape
  final Color overlayColor; // overlay

  const _ImagePreview({
    required this.localPath, // arg
    required this.remoteUrl, // arg
    required this.pending, // arg
    required this.radius, // arg
    required this.overlayColor, // arg
  });

  @override
  Widget build(BuildContext context) {
    final hasLocal = (localPath ?? '').isNotEmpty; // local?
    final hasRemote = (remoteUrl ?? '').isNotEmpty; // remote?

    Widget img; // chosen widget
    if (hasLocal) {
      img = ClipRRect(
        borderRadius: radius, // shape
        child: Image.file(
          File(localPath!), // file
          width: 240,
          height: 280,
          fit: BoxFit.cover, // size
          errorBuilder: (_, __, ___) => _errorBox(), // fallback
        ),
      );
    } else if (hasRemote) {
      img = ClipRRect(
        borderRadius: radius, // shape
        child: Image.network(
          remoteUrl!, // url
          width: 240,
          height: 280,
          fit: BoxFit.cover, // size
          errorBuilder: (_, __, ___) => _errorBox(), // fallback
        ),
      );
    } else {
      img = ClipRRect(borderRadius: radius, child: _errorBox()); // safety
    }

    return Stack(
      alignment: Alignment.center, // center overlay
      children: [
        img, // base
        if (pending)
          Container(
            width: 240,
            height: 280, // match
            decoration: BoxDecoration(
              color: overlayColor, // theme dim
              borderRadius: radius, // same shape
            ),
            child: const Center(
              child: SizedBox(
                width: 28,
                height: 28, // size
                child: CircularProgressIndicator(strokeWidth: 3), // spinner
              ),
            ),
          ),
      ],
    );
  }

  // placeholder for broken/missing
  Widget _errorBox() => Container(
    width: 240,
    height: 160, // size
    color: Colors.black12, // neutral
    alignment: Alignment.center, // center
    child: const Icon(Icons.broken_image_outlined, size: 32), // icon
  );
}

class _MiniStatus extends StatelessWidget {
  final bool isRead; // read?
  final bool isPending; // pending?
  final Color color; // text/icon color
  const _MiniStatus({
    required this.isRead, // ctor
    required this.isPending, // ctor
    required this.color, // ctor
  });

  @override
  Widget build(BuildContext context) {
    final icon = isPending
        ? Icons
              .more_horiz // pending
        : (isRead ? Icons.done_all : Icons.check); // read/delivered
    final label = isPending ? 'Sending…' : (isRead ? 'Read' : 'Sent'); // text
    return Row(
      mainAxisSize: MainAxisSize.min, // compact
      children: [
        Icon(icon, size: 14, color: color), // icon
        const SizedBox(width: 6), // gap
        Text(label, style: TextStyle(color: color, fontSize: 11)), // label
      ],
    );
  }
}
