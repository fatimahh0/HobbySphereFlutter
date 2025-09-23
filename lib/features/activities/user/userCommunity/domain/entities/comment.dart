// lib/features/activities/user/userCommunity/domain/entities/comment.dart
// Flutter 3.35.x — plain immutable entity

class Comment {
  final int id; // comment id
  final String firstName; // author first name
  final String lastName; // author last name
  final String profilePictureUrl; // author avatar
  final String content; // comment text
  final bool isMine; // whether this comment is mine

  const Comment({
    required this.id, // must have id
    required this.firstName, // must have first name
    required this.lastName, // must have last name
    required this.profilePictureUrl, // can be empty string
    required this.content, // text
    required this.isMine, // true/false
  });
}
