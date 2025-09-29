// unchanged (clean state + reload after add)

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/features/activities/user/userCommunity/domain/entities/comment.dart';
import 'package:hobby_sphere/features/activities/user/userCommunity/domain/usecases/add_comment.dart';
import 'package:hobby_sphere/features/activities/user/userCommunity/domain/usecases/get_comments.dart';

class CommentsState {
  final List<Comment> comments;
  final int likeCount;
  final bool loading;
  final String? error;

  const CommentsState({
    this.comments = const [],
    this.likeCount = 0,
    this.loading = false,
    this.error,
  });

  CommentsState copyWith({
    List<Comment>? comments,
    int? likeCount,
    bool? loading,
    String? error,
  }) => CommentsState(
    comments: comments ?? this.comments,
    likeCount: likeCount ?? this.likeCount,
    loading: loading ?? this.loading,
    error: error,
  );
}

class CommentsCubit extends Cubit<CommentsState> {
  final GetComments getComments;
  final AddComment addComment;

  CommentsCubit({required this.getComments, required this.addComment})
    : super(const CommentsState());

  Future<void> load(String token, int postId) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final list = await getComments(token, postId);
      emit(state.copyWith(comments: list, loading: false));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> send(String token, int postId, String text) async {
    if (text.trim().isEmpty) return;
    try {
      await addComment(token, postId, text.trim());
      await load(token, postId);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }
}
