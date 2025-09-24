// lib/features/activities/user/userCommunity/presentation/screens/community_screen.dart
// Flutter 3.35.x — simple, clean, professional, with comments per line

import 'package:flutter/material.dart'; // ui
import 'package:flutter_bloc/flutter_bloc.dart'; // bloc
import 'package:hobby_sphere/features/activities/user/userCommunity/presentation/cubits/unread_cubit.dart';
import 'package:hobby_sphere/features/activities/user/userCommunity/presentation/bloc/posts_bloc.dart';
import 'package:hobby_sphere/features/activities/user/userCommunity/presentation/bloc/posts_event.dart';
import 'package:hobby_sphere/features/activities/user/userCommunity/presentation/bloc/posts_state.dart';
import 'package:hobby_sphere/features/activities/user/userCommunity/presentation/screens/comment_screen.dart';
import 'package:hobby_sphere/features/activities/user/userCommunity/presentation/screens/create_post_screen.dart';

import '../../data/repositories/social_repository_impl.dart'; // repo
import '../../data/services/social_service.dart'; // service
import '../../domain/usecases/get_posts.dart'; // uc
import '../../domain/usecases/toggle_like.dart'; // uc
import '../../domain/usecases/get_unread_notifications.dart'; // uc

import '../widgets/header_icon.dart'; // ui widget
import '../widgets/post_card.dart'; // ui widget
import 'package:hobby_sphere/app/router/router.dart'; // Routes + *MyPostsRouteArgs*
import 'package:hobby_sphere/l10n/app_localizations.dart'; // l10n

class CommunityScreen extends StatelessWidget {
  final String token; // auth token
  final int userId; // ← add this
  final String? imageBaseUrl; // optional base for images
  const CommunityScreen({
    super.key,
    required this.token, // pass token
    required this.userId, // ← require id
    this.imageBaseUrl, // optional
  });

  @override
  Widget build(BuildContext context) {
    final repo = SocialRepositoryImpl(SocialService()); // repo+service
    final tr = AppLocalizations.of(context)!; // l10n

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => PostsBloc(
            // posts bloc
            getPosts: GetPosts(repo), // inject uc
            toggleLike: ToggleLike(repo), // inject uc
          )..add(LoadPosts(token)), // load feed
        ),
        BlocProvider(
          create: (_) => UnreadCubit(
            // alerts cubit
            GetUnreadNotifications(repo), // inject uc
          )..refresh(token), // load badge
        ),
      ],
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background, // theme
        body: SafeArea(
          child: Column(
            children: [
              // ----- sticky header row -----
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8), // spacing
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface, // theme surface
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.06), // soft shadow
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceAround, // even icons
                  children: [
                    // Create Post
                    HeaderIcon(
                      icon: Icons.add_circle_outline, // icon
                      label: tr.socialAddPost, // l10n label
                      onTap: () => Navigator.of(context).pushNamed(
                        Routes.createPost, // go to create
                        arguments: CreatePostArgs(token: token), // pass token
                      ),
                    ),

                    // Search Friend (stub)
                    HeaderIcon(
                      icon: Icons.search_rounded,
                      label: tr.socialSearchFriend,
                      onTap: () {
                        // Open Friends (find/add) — route expects my userId (int)
                        Navigator.of(
                          context,
                        ).pushNamed(Routes.addFriend, arguments: userId);
                      },
                    ),

                    // My Posts (→ THIS is the new wiring)
                    HeaderIcon(
                      icon: Icons.library_books_outlined,
                      label: tr.socialMyPosts,
                      onTap: () {
                        // compute base or reuse given one
                        final base =
                            imageBaseUrl ??
                            ''; // you can also derive from g.appServerRoot
                        Navigator.of(context).pushNamed(
                          Routes.myPosts, // route name
                          arguments: MyPostsRouteArgs(
                            // typed args
                            token: token, // pass token
                            userId: userId, // pass id
                            imageBaseUrl: base, // pass base
                          ),
                        );
                      },
                    ),

                    // Chat (stub)
                    HeaderIcon(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: tr.socialChat,
                      onTap: () {
                        // Open Chat Home — route accepts UserHomeRouteArgs or plain int
                        Navigator.of(context).pushNamed(
                          Routes.friendship,
                          arguments: UserHomeRouteArgs(
                            token: token,
                            userId: userId,
                          ),
                        );
                      },
                      badgeCount:
                          0, // hook up your chat unread count here when ready
                    ),
                    // Notifications (badge from UnreadCubit)
                    BlocBuilder<UnreadCubit, UnreadState>(
                      builder: (ctx, s) => HeaderIcon(
                        icon: Icons.notifications_none_rounded,
                        label: tr.socialNotifications,
                        onTap: () => Navigator.of(context).pushNamed(
                          Routes.userNotifications, // notifications
                          arguments: UserNotificationsRouteArgs(
                            // typed args
                            token: token, // pass token
                          ),
                        ),
                        badgeCount: s.count, // show count
                      ),
                    ),
                  ],
                ),
              ),

              // ----- feed -----
              Expanded(
                child: BlocBuilder<PostsBloc, PostsState>(
                  builder: (context, state) {
                    if (state.loading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      ); // loader
                    }
                    if (state.error != null) {
                      return Center(
                        child: Text(
                          tr.socialError, // l10n error
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      );
                    }
                    if (state.posts.isEmpty) {
                      return Center(
                        child: Text(tr.socialEmpty),
                      ); // empty message
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<PostsBloc>().add(
                          // reload feed
                          LoadPosts(token, forceRefresh: true),
                        );
                        context.read<UnreadCubit>().refresh(
                          token,
                        ); // refresh badge
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.only(
                          top: 8,
                          bottom: 24,
                        ), // list padding
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemCount: state.posts.length, // post count
                        itemBuilder: (_, i) {
                          final p = state.posts[i]; // post
                          return PostCard(
                            post: p, // data
                            imageBaseUrl: imageBaseUrl, // base
                            onToggleLike: () => context.read<PostsBloc>().add(
                              ToggleLikePressed(token, p.id), // like
                            ),
                            onComment: () {
                              // open comments
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => CommentScreen(
                                    args: CommentArgs(
                                      token: token, // pass token
                                      postId: p.id, // pass id
                                      imageBaseUrl: imageBaseUrl, // base
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
