// lib/features/activities/user/userCommunity/presentation/my_posts/my_posts_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/features/activities/user/userCommunity/domain/entities/post.dart';
import 'package:hobby_sphere/features/activities/user/userCommunity/domain/usecases/delete_post.dart';
import 'package:hobby_sphere/features/activities/user/userCommunity/domain/usecases/get_my_posts.dart';

class MyPostsState {
  final List<Post> posts; // current user posts
  final bool loading; // is loading list
  final String? error; // error text (optional)
  final int? deletingId; // post id being deleted (to show spinner)

  const MyPostsState({
    this.posts = const [],
    this.loading = false,
    this.error,
    this.deletingId,
  });

  MyPostsState copyWith({
    List<Post>? posts,
    bool? loading,
    String? error,
    int? deletingId,
  }) => MyPostsState(
    posts: posts ?? this.posts,
    loading: loading ?? this.loading,
    error: error,
    deletingId: deletingId,
  );
}

class MyPostsCubit extends Cubit<MyPostsState> {
  final GetMyPosts getMyPosts; // usecase: load
  final DeletePost deletePost; // usecase: delete

  MyPostsCubit({required this.getMyPosts, required this.deletePost})
    : super(const MyPostsState());

  Future<void> load(String token, int userId) async {
    emit(state.copyWith(loading: true, error: null)); // start loading
    try {
      final list = await getMyPosts(token, userId); // fetch
      emit(state.copyWith(posts: list, loading: false)); // show list
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> remove(String token, int postId) async {
    emit(state.copyWith(deletingId: postId)); // mark one deleting
    try {
      await deletePost(token, postId); // call backend
      final updated = state.posts.where((p) => p.id != postId).toList();
      emit(state.copyWith(posts: updated, deletingId: null)); // remove from UI
    } catch (e) {
      emit(state.copyWith(deletingId: null, error: e.toString())); // clear flag
      rethrow; // let UI toast
    }
  }
}
