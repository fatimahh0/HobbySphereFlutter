class Post {
  final int id;
  final String firstName;
  final String lastName;
  final String profilePictureUrl;
  final String content;
  final String hashtags;
  final String imageUrl;
  final String visibility; // "PUBLIC"/"FRIENDS_ONLY" or "Anyone"/"Friends"
  final DateTime postDatetime;
  final bool isLiked;
  final int likeCount;
  final int commentCount;

  const Post({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.profilePictureUrl,
    required this.content,
    required this.hashtags,
    required this.imageUrl,
    required this.visibility,
    required this.postDatetime,
    required this.isLiked,
    required this.likeCount,
    required this.commentCount,
  });

  Post copyWith({bool? isLiked, int? likeCount, int? commentCount}) {
    return Post(
      id: id,
      firstName: firstName,
      lastName: lastName,
      profilePictureUrl: profilePictureUrl,
      content: content,
      hashtags: hashtags,
      imageUrl: imageUrl,
      visibility: visibility,
      postDatetime: postDatetime,
      isLiked: isLiked ?? this.isLiked,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
    );
  }
}
