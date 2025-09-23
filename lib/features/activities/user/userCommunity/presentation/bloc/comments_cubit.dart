// lib/features/activities/user/userCommunity/presentation/bloc/comments_cubit.dart
// Flutter 3.35.x — cubit with very small, clear state

import 'package:flutter_bloc/flutter_bloc.dart'; // cubit
import 'package:hobby_sphere/features/activities/user/userCommunity/domain/entities/comment.dart';
import 'package:hobby_sphere/features/activities/user/userCommunity/domain/usecases/add_comment.dart';
import 'package:hobby_sphere/features/activities/user/userCommunity/domain/usecases/get_comments.dart';

class CommentsState {
  final List<Comment> comments; // list of comments
  final int likeCount; // optional (not used now)
  final bool loading; // show loader
  final String? error; // last error

  const CommentsState({
    this.comments = const [], // default empty list
    this.likeCount = 0, // default 0
    this.loading = false, // default not loading
    this.error, // default null
  });

  // copyWith to update partial fields
  CommentsState copyWith({
    List<Comment>? comments,
    int? likeCount,
    bool? loading,
    String? error,
  }) => CommentsState(
    comments: comments ?? this.comments, // keep old if null
    likeCount: likeCount ?? this.likeCount,
    loading: loading ?? this.loading,
    error: error, // set new error (can be null)
  );
}

class CommentsCubit extends Cubit<CommentsState> {
  final GetComments getComments; // usecase to fetch comments
  final AddComment addComment; // usecase to add a comment

  CommentsCubit({required this.getComments, required this.addComment})
    : super(const CommentsState()); // init default state

  // load comments for a post
  Future<void> load(String token, int postId) async {
    emit(state.copyWith(loading: true, error: null)); // show loader
    try {
      final list = await getComments(token, postId); // fetch
      emit(state.copyWith(comments: list, loading: false)); // show data
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString())); // show error
    }
  }

  // send a comment then reload the list
  Future<void> send(String token, int postId, String text) async {
    if (text.trim().isEmpty) return; // ignore empty
    try {
      await addComment(token, postId, text.trim()); // send to API
      await load(token, postId); // refresh list
    } catch (e) {
      emit(state.copyWith(error: e.toString())); // store error
      rethrow; // let UI decide toast/snack
    }
  }
}
