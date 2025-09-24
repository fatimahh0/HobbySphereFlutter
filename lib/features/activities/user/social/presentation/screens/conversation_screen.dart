import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/core/network/globals.dart' as g;
import 'package:hobby_sphere/features/activities/user/social/domain/entities/user_min.dart';
import 'package:hobby_sphere/features/activities/user/social/presentation/widgets/chat_bubble.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart'; // pick image

import '../bloc/chat/chat_bloc.dart';
import '../bloc/chat/chat_event.dart';
import '../bloc/chat/chat_state.dart';


// WhatsApp-like conversation UI (text + image).
class ConversationScreen extends StatefulWidget {
  final UserMin peer; // the contact you chat with
  const ConversationScreen({super.key, required this.peer});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final _ctrl = TextEditingController(); // input controller
  final _picker = ImagePicker(); // media picker

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(
      LoadConversation(widget.peer.id),
    ); // load messages
  }

  @override
  void dispose() {
    _ctrl.dispose(); // free controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10 = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

   String? _resolve(String? raw) {
      // make absolute just like UserTile does
      if (raw == null || raw.isEmpty) return null; // nothing
      if (raw.startsWith('http')) return raw; // already absolute
      final root =
          (g.appServerRoot ?? '') // e.g. https://host/api
              .replaceFirst(RegExp(r'/api/?$'), ''); // remove trailing /api
      return raw.startsWith('/') ? '$root$raw' : '$root/$raw'; // join safely
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16, // small avatar
              backgroundColor: cs.surfaceVariant, // fallback color
              backgroundImage: // set only if url ok
              (_resolve(widget.peer.profileImageUrl) != null)
                  ? NetworkImage(_resolve(widget.peer.profileImageUrl)!)
                  : null,
              child: (_resolve(widget.peer.profileImageUrl) == null)
                  ? Text(
                      // initials fallback
                      (widget.peer.firstName.isNotEmpty
                              ? widget.peer.firstName[0]
                              : '?')
                          .toUpperCase(),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Text(widget.peer.fullName),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // messages list
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (_, st) {
                  if (st.isLoading && st.messages.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    reverse: false, // oldest on top
                    itemCount: st.messages.length,
                    itemBuilder: (_, i) => Align(
                      alignment: st.messages[i].isMine
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: ChatBubble(m: st.messages[i]),
                    ),
                  );
                },
              ),
            ),

            // input row
            SafeArea(
              top: false,
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  // add image button
                  IconButton(
                    icon: const Icon(Icons.image_outlined),
                    onPressed: () async {
                      final x = await _picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 80,
                      );
                      if (x != null) {
                        context.read<ChatBloc>().add(
                          SendImage(widget.peer.id, x.path),
                        );
                      }
                    },
                  ),
                  // text field expands
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      minLines: 1,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: l10.friendChat, // keep simple
                        filled: true,
                        fillColor: cs.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // send button
                  IconButton(
                    icon: const Icon(Icons.send_rounded),
                    color: cs.primary,
                    onPressed: () {
                      final txt = _ctrl.text.trim();
                      if (txt.isEmpty) return;
                      context.read<ChatBloc>().add(
                        SendText(widget.peer.id, txt),
                      );
                      _ctrl.clear(); // clear after send
                    },
                  ),
                  const SizedBox(width: 6),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
