// lib/features/activities/user/userCommunity/presentation/screens/comment_screen.dart
// Flutter 3.35.x — Provider<CommentsCubit> fix (Builder), clean UI

import 'package:flutter/material.dart'; // widgets
import 'package:flutter_bloc/flutter_bloc.dart'; // bloc/provider

import 'package:hobby_sphere/features/activities/user/userCommunity/presentation/bloc/comments_cubit.dart';
import '../../data/repositories/social_repository_impl.dart'; // repo impl
import '../../data/services/social_service.dart'; // http service
import '../../domain/usecases/get_comments.dart'; // usecase
import '../../domain/usecases/add_comment.dart'; // usecase

import 'package:hobby_sphere/l10n/app_localizations.dart'; // i18n

// route args from previous screen
class CommentArgs {
  final String token; // user token
  final int postId; // post id
  final String? imageBaseUrl; // optional image base url
  const CommentArgs({
    required this.token, // must pass token
    required this.postId, // must pass id
    this.imageBaseUrl, // optional
  });
}

class CommentScreen extends StatefulWidget {
  final CommentArgs args; // route arguments
  const CommentScreen({super.key, required this.args});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final _ctrl = TextEditingController(); // text input controller

  @override
  void dispose() {
    _ctrl.dispose(); // dispose controller to avoid leaks
    super.dispose();
  }

  // helper: convert relative url -> absolute using base
  String? _abs(String? url) {
    if (url == null || url.isEmpty) return null; // no url
    if (url.startsWith('http')) return url; // already absolute
    final base = (widget.args.imageBaseUrl ?? '').replaceFirst(
      RegExp(r'/$'),
      '',
    ); // trim trailing /
    return '$base$url'; // join
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!; // localizations
    final repo = SocialRepositoryImpl(SocialService()); // repo+service

    return BlocProvider(
      // create the cubit for this screen
      create: (_) => CommentsCubit(
        getComments: GetComments(repo), // inject usecase
        addComment: AddComment(repo), // inject usecase
      )..load(widget.args.token, widget.args.postId), // initial load
      child: Scaffold(
        appBar: AppBar(title: const Text('')), // simple app bar
        body: Column(
          children: [
            // list of comments
            Expanded(
              child: BlocBuilder<CommentsCubit, CommentsState>(
                builder: (context, s) {
                  if (s.loading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    ); // spinner
                  }
                  if (s.comments.isEmpty) {
                    return Center(child: Text(tr.commentEmpty)); // empty view
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(12), // outer padding
                    itemCount: s.comments.length, // item count
                    itemBuilder: (_, i) {
                      final c = s.comments[i]; // comment item
                      final mine = c.isMine; // is my message
                      return Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start, // align top
                        mainAxisAlignment: mine
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          if (!mine)
                            CircleAvatar(
                              backgroundImage: _abs(c.profilePictureUrl) != null
                                  ? NetworkImage(_abs(c.profilePictureUrl)!)
                                  : null, // optional image
                              child: _abs(c.profilePictureUrl) == null
                                  ? const Icon(Icons.person) // fallback icon
                                  : null,
                            ),
                          Flexible(
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ), // bubble margin
                              padding: const EdgeInsets.all(
                                10,
                              ), // bubble padding
                              decoration: BoxDecoration(
                                color: mine
                                    ? Theme.of(
                                        context,
                                      ).colorScheme.primary.withOpacity(.12)
                                    : Theme.of(
                                        context,
                                      ).colorScheme.surfaceVariant,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(mine ? 16 : 8),
                                  topRight: Radius.circular(mine ? 8 : 16),
                                  bottomLeft: const Radius.circular(12),
                                  bottomRight: const Radius.circular(12),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start, // left
                                children: [
                                  Text(
                                    '${c.firstName} ${c.lastName}', // name
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700, // bold
                                      color: mine
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.primary
                                          : Colors.green[800],
                                    ),
                                  ),
                                  const SizedBox(height: 4), // gap
                                  Text(c.content), // text
                                ],
                              ),
                            ),
                          ),
                          if (mine)
                            const CircleAvatar(child: Icon(Icons.person)),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            // input row
            Padding(
              padding: EdgeInsets.only(
                left: 12,
                right: 12,
                top: 8,
                bottom: 12 + MediaQuery.of(context).padding.bottom, // safe area
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl, // bind controller
                      autofocus: true, // focus on open
                      textInputAction:
                          TextInputAction.send, // send from keyboard
                      onSubmitted: (v) =>
                          _sendCurrent(context), // send on submit
                      decoration: InputDecoration(
                        hintText: tr.commentPlaceholder, // hint
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8), // gap
                  // ✅ Builder to get a context under BlocProvider
                  Builder(
                    builder: (ctx) => IconButton(
                      icon: const Icon(Icons.send), // send icon
                      onPressed: () => _sendCurrent(ctx), // send with safe ctx
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // helper to send current text using a context under BlocProvider
  Future<void> _sendCurrent(BuildContext ctx) async {
    final txt = _ctrl.text.trim(); // read text
    if (txt.isEmpty) return; // ignore empty
    try {
      await ctx
          .read<CommentsCubit>() // get cubit safely
          .send(widget.args.token, widget.args.postId, txt); // send to API
      _ctrl.clear(); // clear field
    } catch (_) {
      // optional: show a small error if needed
      ScaffoldMessenger.of(
        ctx,
      ).showSnackBar(const SnackBar(content: Text('Failed to send comment')));
    }
  }
}
