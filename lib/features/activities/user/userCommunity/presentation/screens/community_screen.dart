import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/features/activities/user/userCommunity/presentation/alerts/unread_cubit.dart';
import 'package:hobby_sphere/features/activities/user/userCommunity/presentation/bloc/posts_bloc.dart';
import 'package:hobby_sphere/features/activities/user/userCommunity/presentation/bloc/posts_event.dart';
import 'package:hobby_sphere/features/activities/user/userCommunity/presentation/bloc/posts_state.dart';
import 'package:hobby_sphere/features/activities/user/userCommunity/presentation/screens/comment_screen.dart';
import 'package:hobby_sphere/features/activities/user/userCommunity/presentation/screens/create_post_screen.dart';
import '../../data/repositories/social_repository_impl.dart';
import '../../data/services/social_service.dart';
import '../../domain/usecases/get_posts.dart';
import '../../domain/usecases/toggle_like.dart';
import '../../domain/usecases/get_unread_notifications.dart';

import '../widgets/header_icon.dart';
import '../widgets/post_card.dart';
import 'package:hobby_sphere/app/router/router.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';

class CommunityScreen extends StatelessWidget {
  final String token;
  final String? imageBaseUrl;
  const CommunityScreen({super.key, required this.token, this.imageBaseUrl});

  @override
  Widget build(BuildContext context) {
    final repo = SocialRepositoryImpl(SocialService());
    final tr = AppLocalizations.of(context)!;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              PostsBloc(getPosts: GetPosts(repo), toggleLike: ToggleLike(repo))
                ..add(LoadPosts(token)),
        ),
        BlocProvider(
          create: (_) =>
              UnreadCubit(GetUnreadNotifications(repo))..refresh(token),
        ),
      ],
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: SafeArea(
          child: Column(
            children: [
              // Header row (Post | Search | My Posts | Chat | Alerts)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.06),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    HeaderIcon(
                      icon: Icons.add_circle_outline,
                      label: tr.socialAddPost,
                      onTap: () => Navigator.of(context).pushNamed(
                        Routes.createPost,
                        arguments: CreatePostArgs(token: token),
                      ),
                    ),
                    HeaderIcon(
                      icon: Icons.search_rounded,
                      label: tr.socialSearchFriend,
                      onTap: () {},
                      /*  onTap: () =>
                          Navigator.of(context).pushNamed(Routes.addFriend), */
                    ),
                    HeaderIcon(
                      icon: Icons.library_books_outlined,
                      label: tr.socialMyPosts,
                      onTap: () {},
                      /*   onTap: () =>
                          Navigator.of(context).pushNamed(Routes.myPosts), */
                    ),
                    HeaderIcon(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: tr.socialChat,
                      /*  onTap: () =>
                          Navigator.of(context).pushNamed(Routes.friendship), */
                      badgeCount: 0,
                      onTap:
                          () {}, // wire your chat unread count here if you have it
                    ),
                    BlocBuilder<UnreadCubit, UnreadState>(
                      builder: (ctx, s) => HeaderIcon(
                        icon: Icons.notifications_none_rounded,
                        label: tr.socialNotifications,
                        onTap: () => Navigator.of(context).pushNamed(
                          Routes.userNotifications,
                          arguments: UserNotificationsRouteArgs(token: token),
                        ),
                        badgeCount: s.count,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: BlocBuilder<PostsBloc, PostsState>(
                  builder: (context, state) {
                    if (state.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.error != null) {
                      return Center(
                        child: Text(
                          tr.socialError,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      );
                    }
                    if (state.posts.isEmpty) {
                      return Center(child: Text(tr.socialEmpty));
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<PostsBloc>().add(
                          LoadPosts(token, forceRefresh: true),
                        );
                        context.read<UnreadCubit>().refresh(token);
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.only(top: 8, bottom: 24),
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemCount: state.posts.length,
                        itemBuilder: (_, i) {
                          final p = state.posts[i];
                          return PostCard(
                            post: p,
                            imageBaseUrl: imageBaseUrl,
                            onToggleLike: () => context.read<PostsBloc>().add(
                              ToggleLikePressed(token, p.id),
                            ),
                            // in CommunityScreen, inside itemBuilder where you call onComment:
                            onComment: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => CommentScreen(
                                    args: CommentArgs(
                                      token: token, // pass token
                                      postId: p.id, // pass post id
                                      imageBaseUrl: imageBaseUrl, // optional
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
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
  }
}
