// 💬 ConversationScreen — Flutter 3.35.x
// Non-blocking composer, instant preview, robust rebuild key.

import 'dart:io'; // File check
import 'package:flutter/material.dart'; // UI
import 'package:flutter/services.dart'; // haptics
import 'package:flutter_bloc/flutter_bloc.dart'; // bloc
import 'package:image_picker/image_picker.dart'; // picker

import 'package:hobby_sphere/l10n/app_localizations.dart'; // i18n
import 'package:hobby_sphere/shared/utils/image_resolver.dart'; // url helper

import 'package:hobby_sphere/features/activities/user/social/domain/entities/user_min.dart'; // peer
import '../bloc/chat/chat_bloc.dart'; // bloc
import '../bloc/chat/chat_event.dart'; // events
import '../bloc/chat/chat_state.dart'; // state
import 'package:hobby_sphere/features/activities/user/social/presentation/bloc/friends/friends_bloc.dart'; // optional
import 'package:hobby_sphere/features/activities/user/social/presentation/bloc/friends/friends_event.dart'; // optional
import 'package:hobby_sphere/features/activities/user/social/presentation/widgets/chat_bubble.dart'; // bubble

class ConversationScreen extends StatefulWidget {
  final UserMin peer; // other person
  const ConversationScreen({super.key, required this.peer}); // ctor

  @override
  State<ConversationScreen> createState() => _ConversationScreenState(); // state
}

class _ConversationScreenState extends State<ConversationScreen> {
  final _inputCtrl = TextEditingController(); // input
  final _picker = ImagePicker(); // picker
  final _listCtrl = ScrollController(); // scroll

  bool _blockedLocally = false; // UI-only block

  @override
  void initState() {
    super.initState(); // base
    context.read<ChatBloc>().add(LoadConversation(widget.peer.id)); // load
  }

  @override
  void dispose() {
    _inputCtrl.dispose(); // free
    _listCtrl.dispose(); // free
    super.dispose(); // base
  }

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_listCtrl.hasClients) return; // not ready
      final pos = _listCtrl.position.maxScrollExtent + 48; // extra pad
      if (animated) {
        _listCtrl.animateTo(
          pos,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        ); // smooth
      } else {
        _listCtrl.jumpTo(pos); // snap
      }
    });
  }

  Future<void> _sendText() async {
    final txt = _inputCtrl.text.trim(); // clean
    if (txt.isEmpty) return; // nothing

    FocusScope.of(context).unfocus(); // close ime
    context.read<ChatBloc>().add(SendText(widget.peer.id, txt)); // dispatch
    _inputCtrl.clear(); // clear
    HapticFeedback.lightImpact(); // haptic
    _scrollToBottom(); // to bottom
  }

  Future<void> _pickFromGallery() async {
    final x = await _picker.pickImage(
      source: ImageSource.gallery, // gallery
      imageQuality: 85, // compress
      maxWidth: 1920, // downscale
      maxHeight: 1920, // downscale
    );
    if (x != null) await _sendLocalImage(x); // handle
  }

  Future<void> _pickFromCamera() async {
    final x = await _picker.pickImage(
      source: ImageSource.camera, // camera
      imageQuality: 85, // compress
      maxWidth: 1920, // downscale
      maxHeight: 1920, // downscale
    );
    if (x != null) await _sendLocalImage(x); // handle
  }

  Future<void> _sendLocalImage(XFile x) async {
    if (x.path.isEmpty || !(await File(x.path).exists())) return; // guard
    FocusScope.of(context).unfocus(); // close ime
    context.read<ChatBloc>().add(SendImage(widget.peer.id, x.path)); // dispatch
    HapticFeedback.lightImpact(); // haptic
    _scrollToBottom(); // see preview
  }

  void _openAttachSheet() {
    final cs = Theme.of(context).colorScheme; // colors
    showModalBottomSheet(
      context: context, // ctx
      showDragHandle: true, // handle
      useSafeArea: true, // insets
      backgroundColor: cs.surface, // bg
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)), // round
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 20,
          ), // pad
          child: Wrap(
            runSpacing: 16, // gap
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded), // icon
                title: const Text('Camera'), // text
                onTap: () {
                  Navigator.pop(context); // close
                  _pickFromCamera(); // camera
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded), // icon
                title: const Text('Gallery'), // text
                onTap: () {
                  Navigator.pop(context); // close
                  _pickFromGallery(); // gallery
                },
              ),
              const Divider(height: 24), // line
              Center(
                child: Text(
                  'Attach a photo', // hint
                  style: TextStyle(color: cs.onSurfaceVariant), // subtle
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
    final l10 = AppLocalizations.of(context)!; // i18n
    final cs = Theme.of(context).colorScheme; // colors

    final avatarUrl = resolveUrl(widget.peer.profileImageUrl); // url
    final initials = _initials(
      widget.peer.firstName,
      widget.peer.lastName,
    ); // fallback

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0, // tight
        title: Row(
          children: [
            CircleAvatar(
              radius: 18, // size
              backgroundColor: cs.surfaceVariant, // bg
              child: (avatarUrl == null)
                  ? Text(initials) // initials
                  : ClipOval(
                      child: Image.network(
                        avatarUrl,
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover, // fit
                        errorBuilder: (_, __, ___) =>
                            Text(initials), // fallback
                      ),
                    ),
            ),
            const SizedBox(width: 10), // gap
            Expanded(
              child: Text(
                widget.peer.fullName, // name
                overflow: TextOverflow.ellipsis, // one line
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              switch (v) {
                case 'block':
                  setState(() => _blockedLocally = true); // block
                  _tryFriendsEvent(BlockUser(widget.peer.id)); // dispatch
                  break;
                case 'unblock':
                  setState(() => _blockedLocally = false); // unblock
                  _tryFriendsEvent(UnblockUser(widget.peer.id)); // dispatch
                  break;
                case 'unfriend':
                  _tryFriendsEvent(UnfriendUser(widget.peer.id)); // dispatch
                  break;
              }
            },
            itemBuilder: (_) => [
              if (!_blockedLocally)
                _menu('block', Icons.block, 'Block'), // item
              if (_blockedLocally)
                _menu('unblock', Icons.lock_open, 'Unblock'), // item
              _menu('unfriend', Icons.person_remove_alt_1, 'Unfriend'), // item
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_blockedLocally)
              Container(
                width: double.infinity, // full
                color: cs.errorContainer, // bg
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ), // pad
                child: Text(
                  "You blocked this contact. Unblock to continue chatting.", // msg
                  style: TextStyle(color: cs.onErrorContainer), // fg
                ),
              ),

            Expanded(
              child: BlocConsumer<ChatBloc, ChatState>(
                listener: (_, __) => _scrollToBottom(), // always bottom
                builder: (_, st) {
                  if (st.isLoading && st.messages.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    ); // first load
                  }

                  // KEY FIX: rebuild on last message change (id/url/path)
                  final listKey = ValueKey(
                    st.messages.isEmpty
                        ? 0
                        : '${st.messages.last.id}_${st.messages.last.imageUrl}_${st.messages.last.localImagePath}',
                  );

                  return ListView.builder(
                    key: listKey, // robust key
                    controller: _listCtrl, // scroll
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 8), // pad
                    itemCount: st.messages.length, // count
                    itemBuilder: (_, i) {
                      final m = st.messages[i]; // message
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: 8, // gap
                          left: m.isMine ? 64 : 0, // side margin
                          right: m.isMine ? 0 : 64, // side margin
                        ),
                        child: Align(
                          alignment: m.isMine
                              ? Alignment.centerRight
                              : Alignment.centerLeft, // side
                          child: ChatBubble(m: m), // bubble
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            _blockedLocally
                ? _blockedFooter(context)
                : _composer(context, l10, cs), // bottom
          ],
        ),
      ),
    );
  }

  // composer — non-blocking
  Widget _composer(BuildContext context, AppLocalizations l10, ColorScheme cs) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _inputCtrl, // listen to text
      builder: (_, __, ___) {
        final canSend = _inputCtrl.text.trim().isNotEmpty; // only text check
        return SafeArea(
          top: false, // bottom only
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 6), // pad
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file_rounded), // attach
                  onPressed: _openAttachSheet, // open sheet
                  tooltip: 'Attach', // a11y
                ),
                Expanded(
                  child: TextField(
                    controller: _inputCtrl, // bind
                    minLines: 1,
                    maxLines: 5, // grow
                    textInputAction: TextInputAction.send, // ime action
                    onSubmitted: (_) => _sendText(), // send
                    decoration: InputDecoration(
                      hintText: l10.friendChat, // placeholder
                      filled: true,
                      fillColor: cs.surface, // fill
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20), // round
                        borderSide: BorderSide.none, // none
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ), // pad
                    ),
                  ),
                ),
                const SizedBox(width: 6), // gap
                IconButton.filled(
                  onPressed: canSend ? _sendText : null, // enable rule
                  icon: const Icon(Icons.send_rounded), // icon
                  tooltip: 'Send', // a11y
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _blockedFooter(BuildContext context) {
    final cs = Theme.of(context).colorScheme; // colors
    return SafeArea(
      top: false, // bottom only
      child: Container(
        width: double.infinity, // full
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ), // pad
        color: cs.surface, // bg
        child: Text(
          'Chat disabled (blocked).',
          style: TextStyle(color: cs.onSurfaceVariant),
        ), // text
      ),
    );
  }

  PopupMenuItem<String> _menu(String value, IconData icon, String label) {
    return PopupMenuItem(
      value: value, // id
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label),
        ], // row
      ),
    );
  }

  void _tryFriendsEvent(FriendsEvent e) {
    try {
      context.read<FriendsBloc>().add(e); // dispatch
    } catch (_) {
      // if no FriendsBloc above, ignore
    }
  }

  String _initials(String? f, String? l) {
    final first = (f ?? '').trim(); // first
    final last = (l ?? '').trim(); // last
    if (first.isEmpty && last.isEmpty) return '?'; // none
    if (first.isNotEmpty && last.isNotEmpty) {
      return '${first[0]}${last[0]}'.toUpperCase(); // FL
    }
    return (first.isNotEmpty ? first[0] : last[0]).toUpperCase(); // F or L
  }
}
