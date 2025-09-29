// Flutter 3.35.x — Comments (realtime: add/delete → reload if same post)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/app/bootstrap/start_user_realtime.dart' as rt;

import 'package:hobby_sphere/features/activities/user/userCommunity/presentation/bloc/comments_cubit.dart';
import '../../data/repositories/social_repository_impl.dart';
import '../../data/services/social_service.dart';
import '../../domain/usecases/get_comments.dart';
import '../../domain/usecases/add_comment.dart';

import 'package:hobby_sphere/l10n/app_localizations.dart';

class CommentArgs {
  final String token;
  final int postId;
  final String? imageBaseUrl;
  const CommentArgs({
    required this.token,
    required this.postId,
    this.imageBaseUrl,
  });
}

class CommentScreen extends StatefulWidget {
  final CommentArgs args;
  const CommentScreen({super.key, required this.args});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final _ctrl = TextEditingController();

  void Function(int, Map<String, dynamic>)? _onAdded;
  void Function(int, int)? _onDeleted;

  @override
  void initState() {
    super.initState();
    // when a comment is added/deleted for THIS post → reload
    _onAdded = (pid, full) {
      if (!mounted || pid != widget.args.postId) return;
      context.read<CommentsCubit>().load(widget.args.token, widget.args.postId);
    };
    _onDeleted = (pid, cid) {
      if (!mounted || pid != widget.args.postId) return;
      context.read<CommentsCubit>().load(widget.args.token, widget.args.postId);
    };
    rt.userBridge.onCommentAdded = _onAdded;
    rt.userBridge.onCommentDeleted = _onDeleted;
  }

  @override
  void dispose() {
    if (rt.userBridge.onCommentAdded == _onAdded) {
      rt.userBridge.onCommentAdded = null;
    }
    if (rt.userBridge.onCommentDeleted == _onDeleted) {
      rt.userBridge.onCommentDeleted = null;
    }
    _ctrl.dispose();
    super.dispose();
  }

  String? _abs(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http')) return url;
    final base = (widget.args.imageBaseUrl ?? '').replaceFirst(
      RegExp(r'/$'),
      '',
    );
    return '$base$url';
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final repo = SocialRepositoryImpl(SocialService());

    return BlocProvider(
      create: (_) => CommentsCubit(
        getComments: GetComments(repo),
        addComment: AddComment(repo),
      )..load(widget.args.token, widget.args.postId),
      child: Scaffold(
        appBar: AppBar(title: const Text('')),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<CommentsCubit, CommentsState>(
                builder: (context, s) {
                  if (s.loading)
                    return const Center(child: CircularProgressIndicator());
                  if (s.comments.isEmpty)
                    return Center(child: Text(tr.commentEmpty));
                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: s.comments.length,
                    itemBuilder: (_, i) {
                      final c = s.comments[i];
                      final mine = c.isMine;
                      final dt = c.profilePictureUrl;
                      final avatarUrl = _abs(dt);
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: mine
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          if (!mine)
                            CircleAvatar(
                              backgroundImage: avatarUrl != null
                                  ? NetworkImage(avatarUrl)
                                  : null,
                              child: avatarUrl == null
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                          Flexible(
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              padding: const EdgeInsets.all(10),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${c.firstName} ${c.lastName}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: mine
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.primary
                                          : Colors.green[800],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(c.content),
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
            Padding(
              padding: EdgeInsets.only(
                left: 12,
                right: 12,
                top: 8,
                bottom: 12 + MediaQuery.of(context).padding.bottom,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      autofocus: true,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (v) => _sendCurrent(context),
                      decoration: InputDecoration(
                        hintText: tr.commentPlaceholder,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Builder(
                    builder: (ctx) => IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () => _sendCurrent(ctx),
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

  Future<void> _sendCurrent(BuildContext ctx) async {
    final txt = _ctrl.text.trim();
    if (txt.isEmpty) return;
    try {
      await ctx.read<CommentsCubit>().send(
        widget.args.token,
        widget.args.postId,
        txt,
      );
      _ctrl.clear();
    } catch (_) {
      ScaffoldMessenger.of(
        ctx,
      ).showSnackBar(const SnackBar(content: Text('Failed to send comment')));
    }
  }
}
