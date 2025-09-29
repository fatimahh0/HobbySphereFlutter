// lib/features/activities/user/userCommunity/presentation/screens/community_screen.dart
// Flutter 3.35.x — Community (realtime posts + realtime unread badge)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/app/bootstrap/start_user_realtime.dart' as rt;

import '../../data/repositories/social_repository_impl.dart';
import '../../data/services/social_service.dart';
import '../../domain/usecases/get_posts.dart';
import '../../domain/usecases/toggle_like.dart';

import '../widgets/header_icon.dart';
import '../widgets/post_card.dart';
import 'package:hobby_sphere/app/router/router.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';

import 'package:hobby_sphere/features/activities/user/userCommunity/presentation/screens/comment_screen.dart';
import 'package:hobby_sphere/features/activities/user/userCommunity/presentation/screens/create_post_screen.dart';
import 'package:hobby_sphere/features/activities/user/userCommunity/presentation/bloc/posts_bloc.dart';
import 'package:hobby_sphere/features/activities/user/userCommunity/presentation/bloc/posts_event.dart';
import 'package:hobby_sphere/features/activities/user/userCommunity/presentation/bloc/posts_state.dart';

// ✅ import the realtime-aware unread cubit (shared with Home)
import 'package:hobby_sphere/features/activities/user/userNotification/presentation/bloc/user_unread_cubit.dart';
import 'package:hobby_sphere/features/activities/user/userNotification/data/repositories/user_notification_repository_impl.dart';
import 'package:hobby_sphere/features/activities/user/userNotification/data/services/user_notification_service.dart';

class CommunityScreen extends StatefulWidget {
  final String token;
  final int userId;
  final String? imageBaseUrl;
  const CommunityScreen({
    super.key,
    required this.token,
    required this.userId,
    this.imageBaseUrl,
  });

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  late final SocialRepositoryImpl _repo;
  late final PostsBloc _postsBloc;

  // 🔔 realtime unread cubit (same one Home uses)
  late final UserUnreadNotificationsCubit _unreadCubit;

  // keep exact refs to unbind safely
  void Function(Map<String, dynamic>)? _onPostCreated;
  void Function(int, Map<String, dynamic>)? _onPostUpdated;
  void Function(int)? _onPostDeleted;
  void Function(int, bool)? _onLikeChanged;

  @override
  void initState() {
    super.initState();
    _repo = SocialRepositoryImpl(SocialService());

    _postsBloc = PostsBloc(
      getPosts: GetPosts(_repo),
      toggleLike: ToggleLike(_repo),
    )..add(LoadPosts(widget.token));

    // 🔁 build the unread repo and realtime cubit
    final notifRepo = UserNotificationRepositoryImpl(UserNotificationService());
    _unreadCubit = UserUnreadNotificationsCubit(
      repo: notifRepo,
      token: widget.token,
    )..refresh(); // initial fetch

    // -------- realtime bindings for posts --------
    _onPostCreated = (fullPost) {
      if (!mounted) return;
      _postsBloc.add(LoadPosts(widget.token, forceRefresh: true));
    };
    _onPostUpdated = (postId, patch) {
      if (!mounted) return;
      _postsBloc.add(LoadPosts(widget.token, forceRefresh: true));
    };
    _onPostDeleted = (postId) {
      if (!mounted) return;
      _postsBloc.add(LoadPosts(widget.token, forceRefresh: true));
    };
    _onLikeChanged = (postId, liked) {
      if (!mounted) return;
      _postsBloc.add(LoadPosts(widget.token, forceRefresh: true));
    };

    rt.userBridge.onPostCreated = _onPostCreated;
    rt.userBridge.onPostUpdated = _onPostUpdated;
    rt.userBridge.onPostDeleted = _onPostDeleted;
    rt.userBridge.onLikeChanged = _onLikeChanged;
  }

  @override
  void dispose() {
    if (rt.userBridge.onPostCreated == _onPostCreated) {
      rt.userBridge.onPostCreated = null;
    }
    if (rt.userBridge.onPostUpdated == _onPostUpdated) {
      rt.userBridge.onPostUpdated = null;
    }
    if (rt.userBridge.onPostDeleted == _onPostDeleted) {
      rt.userBridge.onPostDeleted = null;
    }
    if (rt.userBridge.onLikeChanged == _onLikeChanged) {
      rt.userBridge.onLikeChanged = null;
    }
    _postsBloc.close();
    _unreadCubit.close(); // ← close realtime cubit
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _postsBloc),
        BlocProvider.value(value: _unreadCubit), // ← provide realtime unread
      ],
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: SafeArea(
          child: Column(
            children: [
              // header
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
                        arguments: CreatePostArgs(token: widget.token),
                      ),
                    ),
                    HeaderIcon(
                      icon: Icons.search_rounded,
                      label: tr.socialSearchFriend,
                      onTap: () => Navigator.of(
                        context,
                      ).pushNamed(Routes.addFriend, arguments: widget.userId),
                    ),
                    HeaderIcon(
                      icon: Icons.library_books_outlined,
                      label: tr.socialMyPosts,
                      onTap: () {
                        final base = widget.imageBaseUrl ?? '';
                        Navigator.of(context).pushNamed(
                          Routes.myPosts,
                          arguments: MyPostsRouteArgs(
                            token: widget.token,
                            userId: widget.userId,
                            imageBaseUrl: base,
                          ),
                        );
                      },
                    ),
                    HeaderIcon(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: tr.socialChat,
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          Routes.friendship,
                          arguments: UserHomeRouteArgs(
                            token: widget.token,
                            userId: widget.userId,
                          ),
                        );
                      },
                      badgeCount: 0,
                    ),
                    // 🔔 realtime badge here too
                    BlocBuilder<UserUnreadNotificationsCubit, UserUnreadState>(
                      builder: (ctx, s) => HeaderIcon(
                        icon: Icons.notifications_none_rounded,
                        label: tr.socialNotifications,
                        onTap: () => Navigator.of(context).pushNamed(
                          Routes.userNotifications,
                          arguments: UserNotificationsRouteArgs(
                            token: widget.token,
                          ),
                        ),
                        badgeCount: s.count,
                      ),
                    ),
                  ],
                ),
              ),

              // feed
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
                          LoadPosts(widget.token, forceRefresh: true),
                        );
                        context.read<UserUnreadNotificationsCubit>().refresh();
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.only(top: 8, bottom: 24),
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemCount: state.posts.length,
                        itemBuilder: (_, i) {
                          final p = state.posts[i];
                          return PostCard(
                            post: p,
                            imageBaseUrl: widget.imageBaseUrl,
                            onToggleLike: () => context.read<PostsBloc>().add(
                              ToggleLikePressed(widget.token, p.id),
                            ),
                            onComment: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => CommentScreen(
                                    args: CommentArgs(
                                      token: widget.token,
                                      postId: p.id,
                                      imageBaseUrl: widget.imageBaseUrl,
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
