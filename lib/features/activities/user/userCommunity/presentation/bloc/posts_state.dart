import 'package:equatable/equatable.dart';
import 'package:hobby_sphere/features/activities/user/userCommunity/domain/entities/post.dart';

class PostsState extends Equatable {
  final List<Post> posts;
  final bool loading;
  final String? error;

  const PostsState({this.posts = const [], this.loading = false, this.error});

  PostsState copyWith({List<Post>? posts, bool? loading, String? error}) {
    return PostsState(
      posts: posts ?? this.posts,
      loading: loading ?? this.loading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [posts, loading, error];
}
