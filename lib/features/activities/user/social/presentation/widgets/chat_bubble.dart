import 'package:flutter/material.dart';
import '../../domain/entities/chat_message.dart';

// One chat bubble with text or image, aligned left/right.
class ChatBubble extends StatelessWidget {
  final ChatMessage m; // message
  const ChatBubble({super.key, required this.m});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme; // theme
    final align = m.isMine
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start; // alignment by sender
    final bg = m.isMine ? cs.primary : cs.surfaceVariant; // bg color
    final fg = m.isMine ? cs.onPrimary : cs.onSurface; // text color

    final border = RoundedRectangleBorder(
      // rounded bubble
      borderRadius: BorderRadius.only(
        topLeft: const Radius.circular(16),
        topRight: const Radius.circular(16),
        bottomLeft: Radius.circular(m.isMine ? 16 : 4),
        bottomRight: Radius.circular(m.isMine ? 4 : 16),
      ),
    );

    return Column(
      crossAxisAlignment: align, // left/right
      children: [
        Material(
          color: bg, // bubble color
          shape: border, // bubble shape
          child: Padding(
            padding: const EdgeInsets.all(10), // inner padding
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280), // max width
              child: Column(
                crossAxisAlignment: align, // content align
                children: [
                  if (m.imageUrl != null) // show image if any
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(m.imageUrl!, fit: BoxFit.cover),
                    ),
                  if (m.text != null &&
                      m.text!.trim().isNotEmpty) // show text if any
                    Text(m.text!, style: TextStyle(color: fg)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 6), // space after bubble
      ],
    );
  }
}
