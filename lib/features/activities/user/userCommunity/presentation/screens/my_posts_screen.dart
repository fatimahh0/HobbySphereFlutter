// Flutter 3.35.x — My Posts (realtime: refresh on my post create/update/delete)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/app/bootstrap/start_user_realtime.dart' as rt;
import 'package:hobby_sphere/features/activities/user/userCommunity/data/repositories/social_repository_impl.dart';
import 'package:hobby_sphere/features/activities/user/userCommunity/data/services/social_service.dart';
import 'package:hobby_sphere/features/activities/user/userCommunity/domain/usecases/delete_post.dart';
import 'package:hobby_sphere/features/activities/user/userCommunity/domain/usecases/get_my_posts.dart';
import 'package:hobby_sphere/features/activities/user/userCommunity/presentation/cubits/my_posts_cubit.dart';
import 'package:hobby_sphere/features/activities/user/userCommunity/presentation/widgets/my_post_tile.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:hobby_sphere/shared/widgets/top_toast.dart'
    show showTopToast, ToastType;


class MyPostsArgs {
  final String token;
  final int userId;
  final String? imageBaseUrl;
  const MyPostsArgs({
    required this.token,
    required this.userId,
    this.imageBaseUrl,
  });
}

class MyPostsScreen extends StatefulWidget {
  final MyPostsArgs args;
  const MyPostsScreen({super.key, required this.args});

  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  void Function(Map<String, dynamic>)? _onCreated;
  void Function(int, Map<String, dynamic>)? _onUpdated;
  void Function(int)? _onDeleted;

  @override
  void initState() {
    super.initState();
    // when *my* posts change → reload
    _onCreated = (post) {
      final authorId = post['authorId'] as int?;
      if (!mounted || authorId != widget.args.userId) return;
      context.read<MyPostsCubit>().load(widget.args.token, widget.args.userId);
    };
    _onUpdated = (postId, patch) {
      final authorId = patch['authorId'] as int?; // if backend sends it
      if (!mounted) return;
      if (authorId != null && authorId != widget.args.userId) return;
      context.read<MyPostsCubit>().load(widget.args.token, widget.args.userId);
    };
    _onDeleted = (postId) {
      if (!mounted) return;
      context.read<MyPostsCubit>().load(widget.args.token, widget.args.userId);
    };

    rt.userBridge.onPostCreated = _onCreated;
    rt.userBridge.onPostUpdated = _onUpdated;
    rt.userBridge.onPostDeleted = _onDeleted;
  }

  @override
  void dispose() {
    if (rt.userBridge.onPostCreated == _onCreated)
      rt.userBridge.onPostCreated = null;
    if (rt.userBridge.onPostUpdated == _onUpdated)
      rt.userBridge.onPostUpdated = null;
    if (rt.userBridge.onPostDeleted == _onDeleted)
      rt.userBridge.onPostDeleted = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final repo = SocialRepositoryImpl(SocialService());

    return BlocProvider(
      create: (_) => MyPostsCubit(
        getMyPosts: GetMyPosts(repo),
        deletePost: DeletePost(repo),
      )..load(widget.args.token, widget.args.userId),
      child: Scaffold(
        appBar: AppBar(title: Text(tr.myPostsTitle)),
        body: BlocBuilder<MyPostsCubit, MyPostsState>(
          builder: (context, s) {
            if (s.loading)
              return const Center(child: CircularProgressIndicator());
            if (s.error != null) {
              return Center(
                child: Text(
                  tr.socialError,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              );
            }
            if (s.posts.isEmpty) {
              return Center(child: Text(tr.myPostsEmpty));
            }
            return RefreshIndicator(
              onRefresh: () => context.read<MyPostsCubit>().load(
                widget.args.token,
                widget.args.userId,
              ),
              child: ListView.separated(
                padding: const EdgeInsets.only(top: 8, bottom: 24),
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemCount: s.posts.length,
                itemBuilder: (_, i) {
                  final p = s.posts[i];
                  final deleting = s.deletingId == p.id;
                  return MyPostTile(
                    post: p,
                    imageBaseUrl: widget.args.imageBaseUrl,
                    deleting: deleting,
                    onDelete: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(tr.deletePostTitle),
                          content: Text(tr.deletePostConfirm),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: Text(tr.cancel),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: Text(tr.buttonDelete),
                            ),
                          ],
                        ),
                      );
                      if (ok == true) {
                        try {
                          await context.read<MyPostsCubit>().remove(
                            widget.args.token,
                            p.id,
                          );
                          showTopToast(
                            context,
                            tr.deletePostSuccess,
                            type: ToastType.success,
                            haptics: true,
                          );
                        } catch (_) {
                          showTopToast(
                            context,
                            tr.deletePostFailed,
                            type: ToastType.error,
                            haptics: true,
                          );
                        }
                      }
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
