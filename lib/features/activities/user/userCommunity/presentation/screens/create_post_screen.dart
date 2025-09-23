
import 'dart:io'; // File for image preview
import 'package:flutter/material.dart'; // Flutter UI
import 'package:image_picker/image_picker.dart'; // camera/gallery picker

// domain/data imports (your existing layers)
import '../../data/repositories/social_repository_impl.dart'; // repo impl
import '../../data/services/social_service.dart'; // service impl
import '../../domain/usecases/create_post.dart'; // usecase
import 'package:hobby_sphere/l10n/app_localizations.dart'; // localization

// simple args holder (passed from previous screen)
class CreatePostArgs {
  final String token; // user jwt
  const CreatePostArgs({required this.token}); // ctor
}

// main screen widget (stateful for inputs)
class CreatePostScreen extends StatefulWidget {
  final CreatePostArgs args; // route args
  const CreatePostScreen({super.key, required this.args});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

// state class
class _CreatePostScreenState extends State<CreatePostScreen> {
  final _content = TextEditingController(); // text input controller
  final _picker = ImagePicker(); // image picker instance
  String _visibility = 'Anyone'; // 'Anyone' | 'Friends'
  XFile? _picked; // selected image (nullable)
  bool _posting = false; // posting progress flag

  // list of emojis for the feeling picker (30+ items)
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

  // helper: build repo/usecase once per build (cheap)
  CreatePost _usecase(BuildContext context) {
    final repo = SocialRepositoryImpl(SocialService()); // create repo
    return CreatePost(repo); // return usecase
  }

  // show a bottom sheet to choose camera/gallery
  Future<void> _pickImage() async {
    // open a modal bottom sheet (responsive)
    final source = await showModalBottomSheet<ImageSource>(
      context: context, // current context
      showDragHandle: true, // nice handle UI
      shape: const RoundedRectangleBorder(
        // rounded corners
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        // safe area inside sheet
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min, // wrap content
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera), // camera icon
                title: const Text('Camera'), // label
                onTap: () => Navigator.pop(ctx, ImageSource.camera), // choose
              ),
              ListTile(
                leading: const Icon(Icons.photo_library), // gallery icon
                title: const Text('Gallery'), // label
                onTap: () => Navigator.pop(ctx, ImageSource.gallery), // choose
              ),
              const SizedBox(height: 8), // small space
            ],
          ),
        );
      },
    );

    // if user cancels sheet, do nothing
    if (source == null) return;

    // pick image from chosen source
    final picked = await _picker.pickImage(
      source: source, // camera/gallery
      imageQuality: 85, // compress a bit
      maxWidth: 2048, // sensible size
    );

    // update UI if an image was picked
    if (picked != null) {
      setState(() => _picked = picked); // set image
    }
  }

  // show emoji grid bottom sheet
  Future<void> _openEmojiPicker() async {
    // open modal sheet, scrollable
    final emoji = await showModalBottomSheet<String>(
      context: context, // context
      isScrollControlled: true, // allow tall sheet
      showDragHandle: true, // handle bar
      shape: const RoundedRectangleBorder(
        // rounded top
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        // compute grid columns based on width for responsiveness
        final width = MediaQuery.of(ctx).size.width; // screen width
        final columns = width ~/ 56; // ~56 px per tile
        final crossAxisCount = columns.clamp(4, 8); // keep 4..8 columns

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), // inner pad
            child: Column(
              mainAxisSize: MainAxisSize.min, // wrap content
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.emoji_emotions_outlined,
                      color: Colors.orange,
                    ), // icon
                    const SizedBox(width: 8), // gap
                    const Text(
                      'Choose a feeling',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ), // title
                    const Spacer(), // push close button
                    IconButton(
                      icon: const Icon(Icons.close), // close icon
                      onPressed: () => Navigator.pop(ctx), // close
                    ),
                  ],
                ),
                const SizedBox(height: 8), // gap
                Flexible(
                  child: GridView.builder(
                    shrinkWrap: true, // size to content
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount, // responsive columns
                      crossAxisSpacing: 8, // spacing
                      mainAxisSpacing: 8, // spacing
                    ),
                    itemCount: _emojis.length, // emoji count
                    itemBuilder: (_, i) {
                      final e = _emojis[i]; // emoji char
                      return InkWell(
                        borderRadius: BorderRadius.circular(
                          12,
                        ), // ripple radius
                        onTap: () => Navigator.pop(ctx, e), // return emoji
                        child: Container(
                          alignment: Alignment.center, // center emoji
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12), // rounded
                            color: Theme.of(
                              ctx,
                            ).colorScheme.surfaceVariant, // bg
                          ),
                          child: Text(
                            e,
                            style: const TextStyle(fontSize: 24),
                          ), // emoji
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // if an emoji was chosen, append to text
    if (emoji != null && emoji.isNotEmpty) {
      _content.text = (_content.text + ' $emoji').trim(); // append emoji
      _content.selection = TextSelection.fromPosition(
        // move cursor end
        TextPosition(offset: _content.text.length),
      );
      setState(() {}); // refresh UI
    }
  }

  // post action handler
  Future<void> _submit() async {
    // guard if already posting
    if (_posting) return;

    // trim text
    final text = _content.text.trim(); // get content

    // prevent empty post (allow image-only posts if desired)
    final hasImage = _picked != null; // image picked?
    if (text.isEmpty && !hasImage) return; // nothing to post

    // show progress
    setState(() => _posting = true); // lock UI

    try {
      // prepare bytes if image exists
      final bytes = hasImage
          ? await _picked!.readAsBytes()
          : null; // read bytes

      // call usecase (repo → service)
      await _usecase(context)(
        token: widget.args.token, // jwt
        content: text, // text content
        visibility: _visibility, // Anyone/Friends
        imageBytes: bytes, // image bytes
        imageFilename: _picked?.name, // file name
        imageMime: hasImage
            ? 'image/${_picked!.path.split('.').last}' // crude mime guess
            : null, // no image
      );

      // return success to previous screen
      if (mounted) Navigator.pop(context, true); // close with result
    } catch (e) {
      // show simple error
      if (!mounted) return; // widget still here?
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post: $e')), // error text
      );
    } finally {
      // always release progress
      if (mounted) setState(() => _posting = false); // unlock UI
    }
  }

  @override
  void dispose() {
    _content.dispose(); // dispose controller
    super.dispose(); // call super
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!; // localization

    // build responsive layout using LayoutBuilder (prevents overflow)
    return LayoutBuilder(
      builder: (context, constraints) {
        // main scaffold
        return Scaffold(
          appBar: AppBar(
            leading: const CloseButton(), // close button
            title: Text(tr.socialTitle), // title from i18n
            actions: [
              // post button (disabled if empty and no image or posting)
              TextButton(
                onPressed:
                    (_posting ||
                        (_content.text.trim().isEmpty && _picked == null))
                    ? null
                    : _submit, // run submit
                child: _posting
                    ? const SizedBox(
                        // tiny loader
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(tr.createPostPost), // "Post"
              ),
            ],
          ),

          // body with keyboard-aware padding (prevents overflow)
          body: AnimatedPadding(
            duration: const Duration(milliseconds: 150), // smooth shift
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(
                context,
              ).viewInsets.bottom, // keyboard inset
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                // ensures scroll when content > screen height
                padding: const EdgeInsets.all(16), // outer padding
                child: ConstrainedBox(
                  // make column at least as tall as viewport → avoids overflow
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 32,
                  ),
                  child: IntrinsicHeight(
                    // let children size naturally
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch, // full width
                      children: [
                        // content text field
                        TextField(
                          controller: _content, // bind controller
                          minLines: 4, // min height
                          maxLines: 12, // max height
                          textInputAction:
                              TextInputAction.newline, // multi-line
                          decoration: InputDecoration(
                            hintText: tr
                                .createPostPlaceholder, // "What's on your mind?"
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ), // rounded
                            ),
                          ),
                          onChanged: (_) =>
                              setState(() {}), // update Post button
                        ),

                        const SizedBox(height: 12), // gap
                        // action row — use Wrap for responsiveness (no overflow)
                        Wrap(
                          spacing: 12, // horizontal gap
                          runSpacing: 8, // vertical gap on wrap
                          crossAxisAlignment:
                              WrapCrossAlignment.center, // align
                          children: [
                            // photo button → opens camera/gallery chooser
                            OutlinedButton.icon(
                              icon: const Icon(
                                Icons.photo_camera_back_outlined,
                              ), // icon
                              label: Text(tr.createPostPhoto), // label
                              onPressed: _pickImage, // pick image
                            ),

                            // emoji button → opens emoji grid
                            OutlinedButton.icon(
                              icon: const Icon(
                                Icons.emoji_emotions_outlined,
                                color: Colors.orange,
                              ),
                              label: Text(tr.createPostEmojiTitle), // "Feeling"
                              onPressed: _openEmojiPicker, // open picker
                            ),

                            // spacer to push dropdown to the right (when space)
                            const SizedBox(width: 8), // tiny spacer
                            // visibility dropdown wrapped to avoid overflow
                            DropdownButtonHideUnderline(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ), // inner pad
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Theme.of(
                                      context,
                                    ).dividerColor, // border
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    12,
                                  ), // rounded
                                ),
                                child: DropdownButton<String>(
                                  value: _visibility, // current value
                                  borderRadius: BorderRadius.circular(
                                    12,
                                  ), // menu radius
                                  items: [
                                    DropdownMenuItem(
                                      value: 'Anyone', // anyone option
                                      child: Text(
                                        tr.createPostVisibilityAnyone,
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Friends', // friends option
                                      child: Text(
                                        tr.createPostVisibilityFriends,
                                      ),
                                    ),
                                  ],
                                  onChanged: (v) => setState(
                                    () => _visibility = v ?? 'Anyone',
                                  ), // set
                                ),
                              ),
                            ),
                          ],
                        ),

                        // preview image (if any)
                        if (_picked != null) ...[
                          const SizedBox(height: 12), // gap
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12), // rounded
                            child: AspectRatio(
                              aspectRatio: 16 / 9, // responsive ratio
                              child: Image.file(
                                File(_picked!.path), // file path
                                fit: BoxFit.cover, // cover crop
                              ),
                            ),
                          ),
                          const SizedBox(height: 8), // gap
                          Align(
                            alignment: Alignment.centerRight, // right side
                            child: TextButton.icon(
                              icon: const Icon(Icons.close), // remove icon
                              label: const Text('Remove photo'), // text
                              onPressed: () =>
                                  setState(() => _picked = null), // clear
                            ),
                          ),
                        ],

                        const Spacer(), // push actions bottom
                        // bottom hint (optional UX)
                        Text(
                          'Tip: you can add multiple emojis from the picker.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                          textAlign: TextAlign.center, // center text
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
