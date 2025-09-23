// lib/features/activities/user/userCommunity/data/models/comment_model.dart
// Flutter 3.35.x — simple model mapper with safe parsing

import '../../domain/entities/comment.dart'; // import the base entity

class CommentModel extends Comment {
  // pass parsed fields to the base entity
  CommentModel({
    required super.id, // comment id
    required super.firstName, // user first name
    required super.lastName, // user last name
    required super.profilePictureUrl, // user avatar url
    required super.content, // comment text
    required super.isMine, // flag if it's my comment
  });

  // small helper: parse int safely (handles num/string)
  static int _toInt(dynamic v) =>
      v is num ? v.toInt() : int.tryParse('${v ?? 0}') ?? 0;

  // factory to map json -> CommentModel (tolerant to minor key variants)
  factory CommentModel.fromJson(Map<String, dynamic> j) => CommentModel(
    id: _toInt(j['id']), // id as int
    firstName: (j['firstName'] ?? '').toString(), // first name
    lastName: (j['lastName'] ?? '').toString(), // last name
    profilePictureUrl:
        (j['profilePictureUrl'] ?? j['profileImage'] ?? '') // avatar
            .toString(),
    content: (j['content'] ?? '').toString(), // text
    isMine:
        (j['isMine'] == true) || // exact bool
        ('${j['isMine']}'.toLowerCase() == 'true'), // string "true"
  );
}
