// conversation_screen.dart — Flutter 3.35.x
// Pro, stable chat UI with camera/gallery, auto-scroll, nice input, and actions.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/shared/utils/image_resolver.dart';
import 'package:image_picker/image_picker.dart';

import 'package:hobby_sphere/features/activities/user/social/domain/entities/user_min.dart';

import 'package:hobby_sphere/features/activities/user/social/presentation/widgets/chat_bubble.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';

import '../bloc/chat/chat_bloc.dart';
import '../bloc/chat/chat_event.dart';
import '../bloc/chat/chat_state.dart';
// Optional actions if FriendsBloc is provided by parent:
import 'package:hobby_sphere/features/activities/user/social/presentation/bloc/friends/friends_bloc.dart';
import 'package:hobby_sphere/features/activities/user/social/presentation/bloc/friends/friends_event.dart';

class ConversationScreen extends StatefulWidget {
  final UserMin peer; // contact
  const ConversationScreen({super.key, required this.peer});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final _inputCtrl = TextEditingController();
  final _picker = ImagePicker();
  final _listCtrl = ScrollController();

  bool _sending = false; // prevent double-taps while sending
  bool _blockedLocally = false; // simple local banner / disable input

  @override
  void initState() {
    super.initState();
    // Load conversation
    context.read<ChatBloc>().add(LoadConversation(widget.peer.id));
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _listCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_listCtrl.hasClients) return;
      final pos = _listCtrl.position.maxScrollExtent + 48;
      if (animated) {
        _listCtrl.animateTo(
          pos,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      } else {
        _listCtrl.jumpTo(pos);
      }
    });
  }

  Future<void> _sendText() async {
    final txt = _inputCtrl.text.trim();
    if (txt.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      context.read<ChatBloc>().add(SendText(widget.peer.id, txt));
      _inputCtrl.clear();
      _scrollToBottom();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _pickFromGallery() async {
    if (_sending) return;
    final x = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (x != null) {
      setState(() => _sending = true);
      try {
        context.read<ChatBloc>().add(SendImage(widget.peer.id, x.path));
        _scrollToBottom();
      } finally {
        if (mounted) setState(() => _sending = false);
      }
    }
  }

  Future<void> _pickFromCamera() async {
    if (_sending) return;
    final x = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (x != null) {
      setState(() => _sending = true);
      try {
        context.read<ChatBloc>().add(SendImage(widget.peer.id, x.path));
        _scrollToBottom();
      } finally {
        if (mounted) setState(() => _sending = false);
      }
    }
  }

  void _openAttachSheet() {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Wrap(
            runSpacing: 16,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
              const Divider(height: 24),
              Center(
                child: Text(
                  'Attach a photo',
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10 = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    final avatarUrl = resolveUrl(widget.peer.profileImageUrl);
    final initials = _initials(widget.peer.firstName, widget.peer.lastName);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: cs.surfaceVariant,
              child: (avatarUrl == null)
                  ? Text(initials)
                  : ClipOval(
                      child: Image.network(
                        avatarUrl,
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Text(initials),
                      ),
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.peer.fullName,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              switch (v) {
                case 'block':
                  setState(() => _blockedLocally = true);
                  _tryFriendsEvent(BlockUser(widget.peer.id));
                  break;
                case 'unblock':
                  setState(() => _blockedLocally = false);
                  _tryFriendsEvent(UnblockUser(widget.peer.id));
                  break;
                case 'unfriend':
                  _tryFriendsEvent(UnfriendUser(widget.peer.id));
                  break;
              }
            },
            itemBuilder: (_) => [
              if (!_blockedLocally) _menu('block', Icons.block, 'Block'),
              if (_blockedLocally) _menu('unblock', Icons.lock_open, 'Unblock'),
              _menu('unfriend', Icons.person_remove_alt_1, 'Unfriend'),
            ],
          ),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            if (_blockedLocally)
              Container(
                width: double.infinity,
                color: cs.errorContainer,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Text(
                  "You blocked this contact. Unblock to continue chatting.",
                  style: TextStyle(color: cs.onErrorContainer),
                ),
              ),

            // messages list
            Expanded(
              child: BlocConsumer<ChatBloc, ChatState>(
                listener: (_, st) {
                  // auto-scroll when new messages arrive
                  _scrollToBottom();
                },
                builder: (_, st) {
                  if (st.isLoading && st.messages.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return ListView.builder(
                    controller: _listCtrl,
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                    itemCount: st.messages.length,
                    itemBuilder: (_, i) {
                      final m = st.messages[i];
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: 8,
                          left: m.isMine ? 64 : 0,
                          right: m.isMine ? 0 : 64,
                        ),
                        child: Align(
                          alignment: m.isMine
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: ChatBubble(m: m),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // input row
            _blockedLocally
                ? _blockedFooter(context)
                : _composer(context, l10, cs),
          ],
        ),
      ),
    );
  }

  Widget _composer(BuildContext context, AppLocalizations l10, ColorScheme cs) {
    final canSend = _inputCtrl.text.trim().isNotEmpty && !_sending;

    // Rebuild when text changes to toggle send button
    return StatefulBuilder(
      builder: (ctx, setSB) {
        void _onChanged(String _) => setSB(() {});

        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
            child: Row(
              children: [
                // attach
                IconButton(
                  icon: const Icon(Icons.attach_file_rounded),
                  onPressed: _sending ? null : _openAttachSheet,
                ),

                // text field
                Expanded(
                  child: TextField(
                    controller: _inputCtrl,
                    minLines: 1,
                    maxLines: 5,
                    onChanged: _onChanged,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendText(),
                    decoration: InputDecoration(
                      hintText: l10.friendChat,
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
                const SizedBox(width: 6),

                // send
                IconButton.filled(
                  onPressed: canSend ? _sendText : null,
                  icon: _sending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _blockedFooter(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        color: cs.surface,
        child: Text(
          'Chat disabled (blocked).',
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
      ),
    );
  }

  PopupMenuItem<String> _menu(String value, IconData icon, String label) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [Icon(icon, size: 18), const SizedBox(width: 8), Text(label)],
      ),
    );
  }

  void _tryFriendsEvent(FriendsEvent e) {
    try {
      context.read<FriendsBloc>().add(e);
    } catch (_) {
      // FriendsBloc not provided above — ignore, keep UI stable
    }
  }

  String _initials(String? f, String? l) {
    final first = (f ?? '').trim();
    final last = (l ?? '').trim();
    if (first.isEmpty && last.isEmpty) return '?';
    if (first.isNotEmpty && last.isNotEmpty) {
      return '${first[0]}${last[0]}'.toUpperCase();
    }
    return (first.isNotEmpty ? first[0] : last[0]).toUpperCase();
  }
}
