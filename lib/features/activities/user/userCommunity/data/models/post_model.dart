// lib/features/activities/user/userCommunity/data/models/post_model.dart
// Flutter 3.35.x – simple, clean, professional, with comments

import '../../domain/entities/post.dart'; // base entity class

class PostModel extends Post {
  // pass values to base entity
  PostModel({
    required super.id, // numeric id
    required super.firstName, // first name
    required super.lastName, // last name
    required super.profilePictureUrl, // avatar (may be http or relative)
    required super.content, // post text
    required super.hashtags, // tags string (can be empty)
    required super.imageUrl, // image url (empty if none)
    required super.visibility, // "PUBLIC" or "FRIENDS_ONLY"
    required super.postDatetime, // created datetime
    required super.isLiked, // did current user like
    required super.likeCount, // number of likes
    required super.commentCount, // number of comments
  });

  // tiny helpers to parse safely
  static int _toInt(dynamic v) =>
      v is num ? v.toInt() : int.tryParse('${v ?? 0}') ?? 0; // int or 0

  static bool _toBool(dynamic v) {
    if (v is bool) return v; // already bool
    if (v is num) return v != 0; // 0/1 as bool
    final s = ('${v ?? ''}').toLowerCase().trim(); // string cases
    return s == 'true' || s == '1';
  }

  // normalize visibility to your two values
  static String _vis(dynamic v) {
    final s = ('${v ?? 'PUBLIC'}').toUpperCase(); // string or PUBLIC
    if (s.contains('FRIEND')) return 'FRIENDS_ONLY'; // friends only
    return 'PUBLIC'; // default public
  }

  // factory from backend JSON (matches your sample)
  factory PostModel.fromJson(Map<String, dynamic> j) {
    // read simple fields, coalesce nulls to empty strings
    final id = _toInt(j['id']); // 1,3,4,5,7,...
    final first = (j['firstName'] ?? '').toString(); // Hussein, georges...
    final last = (j['lastName'] ?? '').toString(); // Kassem, leb...
    final avatar = (j['profilePictureUrl'] ?? '').toString(); // http url
    final content = (j['content'] ?? '').toString(); // "Hi", "😍", ...
    final hashtags = (j['hashtags'] ?? '').toString(); // null -> ''
    final image = (j['imageUrl'] ?? '').toString(); // null -> ''
    final isLiked = _toBool(j['isLiked']); // false/true
    final likeCount = _toInt(j['likeCount']); // 0..n
    final commentCount = _toInt(j['commentCount']); // 0..n
    final visibility = _vis(j['visibility']); // PUBLIC/FRIENDS_ONLY

    // parse date safely; fallback to epoch if parse fails
    final createdStr = (j['postDatetime'] ?? '').toString(); // ISO string
    final created =
        DateTime.tryParse(createdStr) // try parse
        ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true); // safe fallback

    // build model
    return PostModel(
      id: id,
      firstName: first,
      lastName: last,
      profilePictureUrl: avatar,
      content: content,
      hashtags: hashtags,
      imageUrl: image,
      visibility: visibility,
      postDatetime: created,
      isLiked: isLiked,
      likeCount: likeCount,
      commentCount: commentCount,
    );
  }
}
