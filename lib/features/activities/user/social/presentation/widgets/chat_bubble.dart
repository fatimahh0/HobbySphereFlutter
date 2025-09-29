import 'package:flutter/material.dart';
import 'package:hobby_sphere/shared/utils/image_resolver.dart';
import '../../domain/entities/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage m;
  const ChatBubble({super.key, required this.m});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isMe = m.isMine;

    // Cap bubble width to 80% of screen or 360px, whichever smaller
    final screen = MediaQuery.of(context).size.width;
    final maxW = screen * 0.8;
    final cap = maxW < 360 ? maxW : 360.0;

    final bg = isMe ? cs.primary : cs.surfaceVariant;
    final fg = isMe ? cs.onPrimary : cs.onSurface;

    final radius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(isMe ? 16 : 4),
      bottomRight: Radius.circular(isMe ? 4 : 16),
    );

    final imgUrl = resolveUrl(m.imageUrl);
    final tsText = _fmt(m.sentAt);
    final tick = isMe
        ? Icon(
            m.isRead ? Icons.done_all_rounded : Icons.check_rounded,
            size: 14,
            color: m.isRead ? Colors.lightBlueAccent : fg.withOpacity(0.85),
          )
        : const SizedBox.shrink();

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: cap),
        child: Material(
          color: bg,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (imgUrl != null && imgUrl.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _NetImage(imgUrl: imgUrl),
                  ),
                  if ((m.text ?? '').trim().isNotEmpty)
                    const SizedBox(height: 8),
                ],
                if ((m.text ?? '').trim().isNotEmpty)
                  // Use SelectableText for long URLs; allows wrapping without overflow.
                  SelectableText(
                    m.text!,
                    style: TextStyle(color: fg, height: 1.25),
                  ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tsText,
                      style: TextStyle(
                        color: fg.withOpacity(0.65),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 6),
                    tick,
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _fmt(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _NetImage extends StatelessWidget {
  final String imgUrl;
  const _NetImage({required this.imgUrl});

  @override
  Widget build(BuildContext context) {
    // Keep images within 80% width and ~40% height of screen to avoid overflow.
    final size = MediaQuery.of(context).size;
    final maxW = size.width * 0.8;
    final maxH = size.height * 0.4;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxW,
        maxHeight: maxH,
        // give a reasonable min height so layout doesn’t jump while loading
        minHeight: 140,
      ),
      child: Image.network(
        imgUrl,
        fit: BoxFit.cover,
        loadingBuilder: (ctx, child, progress) {
          if (progress == null) return child;
          return Container(
            alignment: Alignment.center,
            child: const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (_, __, ___) => Container(
          alignment: Alignment.center,
          color: Theme.of(context).colorScheme.surface,
          child: Icon(
            Icons.broken_image_outlined,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
