import 'package:image_picker/image_picker.dart';
import '../entities/business_profile.dart';
import '../repositories/registration_repository.dart';

class CompleteBusinessProfile {
  final RegistrationRepository repo;
  CompleteBusinessProfile(this.repo);
  Future<BusinessProfile> call({
    required int pendingId,
    required String name,
    String? description,
    String? websiteUrl,
    XFile? logo,
    XFile? banner,
  }) => repo.completeBusinessProfile(
    pendingId: pendingId,
    name: name,
    description: description,
    websiteUrl: websiteUrl,
    logo: logo,
    banner: banner,
  );
}
