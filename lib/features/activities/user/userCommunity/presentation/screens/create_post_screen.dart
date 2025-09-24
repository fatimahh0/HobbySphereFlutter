// lib/features/activities/user/userCommunity/presentation/screens/create_post_screen.dart
// Flutter 3.35.x — Professional Create Post screen (responsive, no overflow)
// - Polished Material 3 design (cards, shadows, rounded corners)
// - Keyboard-safe (AnimatedPadding), always scrollable (SingleChildScrollView)
// - Responsive actions (Wrap) so nothing overflows on small screens
// - Camera or Gallery picker (bottom sheet)
// - Pro Emoji panel (draggable, responsive grid, search-ready structure)
// - Live character counter + disabled Post when empty (unless photo-only allowed)

import 'dart:io'; // file preview
import 'package:flutter/material.dart'; // flutter UI
import 'package:image_picker/image_picker.dart'; // camera/gallery

// your layers
import '../../data/repositories/social_repository_impl.dart'; // repo impl
import '../../data/services/social_service.dart'; // service
import '../../domain/usecases/create_post.dart'; // usecase
import 'package:hobby_sphere/l10n/app_localizations.dart'; // i18n

// route args
class CreatePostArgs {
  final String token; // user token
  const CreatePostArgs({required this.token}); // ctor
}

class CreatePostScreen extends StatefulWidget {
  final CreatePostArgs args; // args
  const CreatePostScreen({super.key, required this.args});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _content = TextEditingController(); // text controller
  final _picker = ImagePicker(); // image picker
  String _visibility = 'Anyone'; // Anyone|Friends
  XFile? _picked; // selected image
  bool _posting = false; // loading state
  static const int _maxChars = 500; // content limit

  // curated emoji list (feelings) — you can extend later
  static const List<String> _emojis = [
    '😀',
    '😄',
    '😁',
    '😆',
    '🥹',
    '😊',
    '🙂',
    '😉',
    '😍',
    '🥰',
    '😘',
    '😗',
    '😚',
    '😙',
    '😋',
    '😜',
    '🤪',
    '🤩',
    '🤗',
    '🤔',
    '🤨',
    '😐',
    '😑',
    '😶',
    '🙄',
    '😮',
    '😴',
    '🤤',
    '😪',
    '😷',
    '🤒',
    '🤕',
    '🤧',
    '🥵',
    '🥶',
    '🥳',
    '😎',
    '🫡',
    '🤝',
    '💪',
    '🙏',
    '👍',
    '🔥',
    '✨',
    '🎉',
  ];

  // get CreatePost usecase (simple factory)
  CreatePost _usecase() => CreatePost(SocialRepositoryImpl(SocialService()));

  // open source chooser (camera/gallery)
  Future<void> _pickImage() async {
    // bottom sheet for source
    final source = await showModalBottomSheet<ImageSource>(
      context: context, // ctx
      showDragHandle: true, // handle
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)), // round
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min, // wrap
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded), // icon
              title: const Text('Take a photo'), // text
              onTap: () => Navigator.pop(ctx, ImageSource.camera), // choose
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded), // icon
              title: const Text('Choose from gallery'), // text
              onTap: () => Navigator.pop(ctx, ImageSource.gallery), // choose
            ),
            const SizedBox(height: 8), // gap
          ],
        ),
      ),
    );

    // user canceled
    if (source == null) return;

    // pick image
    final file = await _picker.pickImage(
      source: source, // src
      imageQuality: 85, // compress
      maxWidth: 2048, // scale
    );

    // set state if picked
    if (file != null) setState(() => _picked = file); // save
  }

  // open emoji panel (draggable sheet)
  Future<void> _openEmojiPanel() async {
    // show draggable scrollable sheet for pro feel
    final emoji = await showModalBottomSheet<String>(
      context: context, // ctx
      isScrollControlled: true, // tall
      showDragHandle: true, // handle
      backgroundColor: Theme.of(context).colorScheme.surface, // surface
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)), // round
      ),
      builder: (ctx) {
        // compute columns based on width (responsive)
        final w = MediaQuery.of(ctx).size.width; // width
        final cols = (w / 60).floor().clamp(4, 10); // 4..10

        // build sheet
        return DraggableScrollableSheet(
          expand: false, // float
          initialChildSize: 0.5, // 50% h
          minChildSize: 0.35, // 35% h
          maxChildSize: 0.9, // 90% h
          builder: (_, controller) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), // pad
              child: Column(
                children: [
                  // header row
                  Row(
                    children: [
                      const Icon(
                        Icons.emoji_emotions,
                        color: Colors.orange,
                      ), // icon
                      const SizedBox(width: 8), // gap
                      const Text(
                        'Add a feeling',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ), // title
                      const Spacer(), // push
                      IconButton(
                        icon: const Icon(Icons.close_rounded), // close
                        onPressed: () => Navigator.pop(ctx), // pop
                      ),
                    ],
                  ),
                  const SizedBox(height: 8), // gap
                  // grid of emojis
                  Expanded(
                    child: GridView.builder(
                      controller: controller, // drag
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols, // cols
                        crossAxisSpacing: 10, // gap
                        mainAxisSpacing: 10, // gap
                      ),
                      itemCount: _emojis.length, // len
                      itemBuilder: (_, i) {
                        final e = _emojis[i]; // item
                        return InkWell(
                          borderRadius: BorderRadius.circular(12), // ripple
                          onTap: () => Navigator.pop(ctx, e), // pick
                          child: Container(
                            alignment: Alignment.center, // center
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12), // round
                              color: Theme.of(
                                ctx,
                              ).colorScheme.surfaceVariant, // bg
                            ),
                            child: Text(
                              e,
                              style: const TextStyle(fontSize: 26),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    // append emoji to content
    if (emoji != null && emoji.isNotEmpty) {
      _content.text = (_content.text + ' $emoji').trim(); // add
      _content.selection = TextSelection.fromPosition(
        // caret
        TextPosition(offset: _content.text.length), // end
      );
      setState(() {}); // refresh
    }
  }

  // submit post
  Future<void> _submit() async {
    // prevent double taps
    if (_posting) return;

    // read content
    final text = _content.text.trim(); // text
    final hasImage = _picked != null; // img?

    // do not allow empty (unless you want image-only posts → keep hasImage)
    if (text.isEmpty && !hasImage) return; // guard

    // lock UI
    setState(() => _posting = true); // busy

    try {
      // prepare image bytes
      final bytes = hasImage ? await _picked!.readAsBytes() : null; // bytes

      // call usecase
      await _usecase()(
        token: widget.args.token, // jwt
        content: text, // body
        visibility: _visibility, // vis
        imageBytes: bytes, // img
        imageFilename: _picked?.name, // name
        imageMime: hasImage ? 'image/${_picked!.path.split('.').last}' : null,
      );

      // pop success
      if (mounted) Navigator.pop(context, true); // done
    } catch (e) {
      // simple error toast
      if (!mounted) return; // safe
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post: $e')), // msg
      );
    } finally {
      // unlock UI
      if (mounted) setState(() => _posting = false); // idle
    }
  }

  @override
  void dispose() {
    _content.dispose(); // clean
    super.dispose(); // super
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!; // i18n

    // keyboard-aware padding to avoid overflow
    final bottomInset = MediaQuery.of(context).viewInsets.bottom; // kb h

    // main scaffold
    return Scaffold(
      // modern app bar with filled “Post” button
      appBar: AppBar(
        title: Text(tr.socialTitle), // title
        leading: const CloseButton(), // close
        actions: [
          // primary Post action
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0), // pad
            child: FilledButton(
              onPressed:
                  (_posting ||
                      (_content.text.trim().isEmpty && _picked == null))
                  ? null // disable
                  : _submit, // submit
              child: _posting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(tr.createPostPost), // label
            ),
          ),
        ],
      ),

      // body wrapped in AnimatedPadding so keyboard never overflows content
      body: AnimatedPadding(
        duration: const Duration(milliseconds: 150), // smooth
        curve: Curves.easeOut, // curve
        padding: EdgeInsets.only(bottom: bottomInset), // kb pad
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, c) => SingleChildScrollView(
              padding: const EdgeInsets.all(16), // outer
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: c.maxHeight - 32,
                ), // fill
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch, // full
                  children: [
                    // main card (pro look)
                    Card(
                      elevation: 1, // subtle
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16), // round
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14), // inner
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // visibility row (compact pro control)
                            Row(
                              children: [
                                Icon(
                                  _visibility == 'Friends'
                                      ? Icons.people_alt_rounded
                                      : Icons.public_rounded, // icon
                                  size: 18,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8), // gap
                                DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _visibility, // value
                                    borderRadius: BorderRadius.circular(12),
                                    onChanged: (v) => setState(
                                      () => _visibility = v ?? 'Anyone',
                                    ),
                                    items: [
                                      DropdownMenuItem(
                                        value: 'Anyone',
                                        child: Text(
                                          tr.createPostVisibilityAnyone,
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Friends',
                                        child: Text(
                                          tr.createPostVisibilityFriends,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(), // push
                                // live counter (pro feel)
                                Text(
                                  '${_content.text.characters.length}/$_maxChars',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: _content.text.length > _maxChars
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.error
                                            : Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 6), // gap
                            // text field (large, modern)
                            TextField(
                              controller: _content, // bind
                              minLines: 4, // min
                              maxLines: 12, // max
                              maxLength: _maxChars, // limit
                              decoration: InputDecoration(
                                counterText:
                                    '', // hide long counter (we show custom)
                                hintText: tr.createPostPlaceholder, // hint
                                filled: true, // filled
                                fillColor: Theme.of(context)
                                    .colorScheme
                                    .surfaceVariant
                                    .withOpacity(.4), // soft bg
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none, // clean
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onChanged: (_) => setState(() {}), // refresh
                              textInputAction:
                                  TextInputAction.newline, // newline
                            ),

                            // image preview (if any)
                            if (_picked != null) ...[
                              const SizedBox(height: 10), // gap
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  12,
                                ), // round
                                child: AspectRatio(
                                  aspectRatio: 16 / 9, // ratio
                                  child: Image.file(
                                    File(_picked!.path), // file
                                    fit: BoxFit.cover, // cover
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight, // right
                                child: TextButton.icon(
                                  icon: const Icon(Icons.close_rounded), // icon
                                  label: const Text('Remove photo'), // text
                                  onPressed: () =>
                                      setState(() => _picked = null),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12), // gap
                    // bottom action bar (pro, responsive with Wrap)
                    Card(
                      elevation: 0, // flat
                      color: Theme.of(context).colorScheme.surface, // surface
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14), // round
                        side: BorderSide(
                          color: Theme.of(context).dividerColor, // border
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10), // inner
                        child: Wrap(
                          spacing: 12, // h gap
                          runSpacing: 8, // v gap
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            // photo button (opens camera/gallery sheet)
                            OutlinedButton.icon(
                              icon: const Icon(Icons.add_a_photo_rounded),
                              label: Text(tr.createPostPhoto),
                              onPressed: _pickImage,
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),

                            // emoji panel opener
                            OutlinedButton.icon(
                              icon: const Icon(
                                Icons.emoji_emotions_outlined,
                                color: Colors.orange,
                              ),
                              label: Text(tr.createPostEmojiTitle),
                              onPressed: _openEmojiPanel,
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),

                            // quick emoji suggestions (top 4, as chips)
                            ..._emojis
                                .take(4)
                                .map(
                                  (e) => ActionChip(
                                    label: Text(e), // emoji
                                    onPressed: () {
                                      _content.text = (_content.text + ' $e')
                                          .trim();
                                      _content.selection =
                                          TextSelection.fromPosition(
                                            TextPosition(
                                              offset: _content.text.length,
                                            ),
                                          );
                                      setState(() {});
                                    },
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16), // bottom space
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
