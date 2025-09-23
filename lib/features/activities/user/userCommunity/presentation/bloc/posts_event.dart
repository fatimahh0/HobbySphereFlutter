import 'package:equatable/equatable.dart';

abstract class PostsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadPosts extends PostsEvent {
  final String token;
  final bool forceRefresh;
  LoadPosts(this.token, {this.forceRefresh = false});
}

class ToggleLikePressed extends PostsEvent {
  final String token;
  final int postId;
  ToggleLikePressed(this.token, this.postId);
}
