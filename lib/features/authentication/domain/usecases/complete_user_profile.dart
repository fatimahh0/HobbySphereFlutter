import 'package:hobby_sphere/features/authentication/domain/entities/user_profile.dart';
import 'package:image_picker/image_picker.dart';

import '../repositories/registration_repository.dart';

class CompleteUserProfile {
  final RegistrationRepository repo;
  CompleteUserProfile(this.repo);
  Future<UserProfile> call({
    required int pendingId,
    required String username,
    required String firstName,
    required String lastName,
    required bool isPublic,
    XFile? image,
  }) => repo.completeUserProfile(
    pendingId: pendingId,
    username: username,
    firstName: firstName,
    lastName: lastName,
    isPublic: isPublic,
    image: image,
  );
}
