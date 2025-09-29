import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/features/activities/user/userCommunity/domain/usecases/get_posts.dart';
import 'package:hobby_sphere/features/activities/user/userCommunity/domain/usecases/toggle_like.dart';
import 'posts_event.dart';
import 'posts_state.dart';

class PostsBloc extends Bloc<PostsEvent, PostsState> {
  final GetPosts getPosts;
  final ToggleLike toggleLike;

  PostsBloc({required this.getPosts, required this.toggleLike})
    : super(const PostsState()) {
    on<LoadPosts>((e, emit) async {
      emit(state.copyWith(loading: true, error: null));
      try {
        final list = await getPosts(e.token);
        emit(state.copyWith(posts: list, loading: false));
      } catch (err) {
        emit(state.copyWith(loading: false, error: err.toString()));
      }
    });

    on<ToggleLikePressed>((e, emit) async {
      // optimistic
      final updated = state.posts.map((p) {
        if (p.id == e.postId) {
          final liked = !p.isLiked;
          final cnt = liked
              ? p.likeCount + 1
              : (p.likeCount - 1).clamp(0, 1 << 31);
          return p.copyWith(isLiked: liked, likeCount: cnt);
        }
        return p;
      }).toList();
      emit(state.copyWith(posts: updated));

      try {
        await toggleLike(e.token, e.postId);
      } catch (_) {
        // revert
        final reverted = state.posts.map((p) {
          if (p.id == e.postId) {
            final liked = !p.isLiked;
            final cnt = liked
                ? p.likeCount + 1
                : (p.likeCount - 1).clamp(0, 1 << 31);
            return p.copyWith(isLiked: liked, likeCount: cnt);
          }
          return p;
        }).toList();
        emit(state.copyWith(posts: reverted));
      }
    });
  }
}
