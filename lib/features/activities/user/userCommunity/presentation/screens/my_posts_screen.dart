// lib/.../my_posts/my_posts_screen.dart
// Flutter 3.35.x — l10n + theme friendly + TOP TOAST

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/features/activities/user/userCommunity/data/repositories/social_repository_impl.dart';
import 'package:hobby_sphere/features/activities/user/userCommunity/data/services/social_service.dart';
import 'package:hobby_sphere/features/activities/user/userCommunity/domain/usecases/delete_post.dart';
import 'package:hobby_sphere/features/activities/user/userCommunity/domain/usecases/get_my_posts.dart';
import 'package:hobby_sphere/features/activities/user/userCommunity/presentation/cubits/my_posts_cubit.dart';
import 'package:hobby_sphere/features/activities/user/userCommunity/presentation/widgets/my_post_tile.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:hobby_sphere/shared/widgets/top_toast.dart' show showTopToast, ToastType;


class MyPostsArgs {
  final String token; // token
  final int userId; // user id
  final String? imageBaseUrl; // base for images
  const MyPostsArgs({
    required this.token,
    required this.userId,
    this.imageBaseUrl,
  });
}

class MyPostsScreen extends StatelessWidget {
  final MyPostsArgs args; // route args
  const MyPostsScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!; // ← localization
    final repo = SocialRepositoryImpl(SocialService()); // repo + service

    return BlocProvider(
      create: (_) => MyPostsCubit(
        getMyPosts: GetMyPosts(repo), // usecase: load
        deletePost: DeletePost(repo), // usecase: delete
      )..load(args.token, args.userId), // initial fetch
      child: Scaffold(
        appBar: AppBar(title: Text(tr.myPostsTitle)), // ← l10n title
        body: BlocBuilder<MyPostsCubit, MyPostsState>(
          builder: (context, s) {
            // loading spinner
            if (s.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            // error state (theme error color)
            if (s.error != null) {
              return Center(
                child: Text(
                  tr.socialError, // or s.error
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              );
            }

            // empty state
            if (s.posts.isEmpty) {
              return Center(child: Text(tr.myPostsEmpty));
            }

            // list with pull-to-refresh
            return RefreshIndicator(
              onRefresh: () =>
                  context.read<MyPostsCubit>().load(args.token, args.userId),
              child: ListView.separated(
                padding: const EdgeInsets.only(top: 8, bottom: 24),
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemCount: s.posts.length,
                itemBuilder: (_, i) {
                  final p = s.posts[i];
                  final deleting = s.deletingId == p.id;

                  return MyPostTile(
                    post: p,
                    imageBaseUrl: args.imageBaseUrl,
                    deleting: deleting,
                    onDelete: () async {
                      // confirm dialog
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
                            args.token,
                            p.id,
                          );

                          // ✅ top toast on success
                          showTopToast(
                            context,
                            tr.deletePostSuccess, // “Post deleted”
                            type: ToastType.success,
                            haptics: true,
                          );
                        } catch (_) {
                          // ❌ top toast on failure
                          showTopToast(
                            context,
                            tr.deletePostFailed, // “Failed to delete post”
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
