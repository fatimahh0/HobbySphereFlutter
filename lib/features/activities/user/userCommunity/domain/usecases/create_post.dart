import '../repositories/social_repository.dart';

class CreatePost {
  final SocialRepository repo;
  CreatePost(this.repo);
  Future<void> call({
    required String token,
    required String content,
    String? hashtags,
    String? visibility,
    List<int>? imageBytes,
    String? imageFilename,
    String? imageMime,
  }) => repo.createPost(
    token: token,
    content: content,
    hashtags: hashtags,
    visibility: visibility,
    imageBytes: imageBytes,
    imageFilename: imageFilename,
    imageMime: imageMime,
  );
}
