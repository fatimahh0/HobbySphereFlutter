import 'package:image_picker/image_picker.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/business_profile.dart';
import '../../domain/repositories/registration_repository.dart';
import '../services/registration_service.dart';

class RegistrationRepositoryImpl implements RegistrationRepository {
  final RegistrationService api;
  RegistrationRepositoryImpl(this.api);

  // USER
  @override
  Future<void> sendUserVerification({
    String? email,
    String? phone,
    required String password,
  }) => api.sendUserVerification(
    email: email,
    phoneNumber: phone,
    password: password,
  );

  @override
  Future<int> verifyUserEmailCode(String email, String code) =>
      api.verifyUserEmailCode(email, code);

  @override
  Future<int> verifyUserPhoneCode(String phone, String code) =>
      api.verifyUserPhoneCode(phone, code);

  @override
  Future<UserProfile> completeUserProfile({
    required int pendingId,
    required String username,
    required String firstName,
    required String lastName,
    required bool isPublic,
    XFile? image,
  }) async {
    final m = await api.completeUserProfile(
      pendingId: pendingId,
      username: username,
      firstName: firstName,
      lastName: lastName,
      isPublicProfile: isPublic,
      profileImage: image,
    );
    return UserProfile.fromMap(m);
  }

  @override
  Future<void> addUserInterests(int userId, List<int> ids) =>
      api.addUserInterests(userId, ids);

  @override
  Future<void> resendUserCode(String contact) => api.resendUserCode(contact);

  // BUSINESS
  @override
  Future<int> sendBusinessVerification({
    String? email,
    String? phone,
    required String password,
  }) => api.sendBusinessVerification(
    email: email,
    phoneNumber: phone,
    password: password,
  );

  @override
  Future<int> verifyBusinessEmailCode(String email, String code) =>
      api.verifyBusinessEmailCode(email, code);

  @override
  Future<int> verifyBusinessPhoneCode(String phone, String code) =>
      api.verifyBusinessPhoneCode(phone, code);

  @override
  Future<BusinessProfile> completeBusinessProfile({
    required int pendingId,
    required String name,
    String? description,
    String? websiteUrl,
    XFile? logo,
    XFile? banner,
  }) async {
    final m = await api.completeBusinessProfile(
      pendingId: pendingId,
      businessName: name,
      description: description,
      websiteUrl: websiteUrl,
      logo: logo,
      banner: banner,
    );
    return BusinessProfile.fromMap(m);
  }

  @override
  Future<void> resendBusinessCode(String contact) =>
      api.resendBusinessCode(contact);
}
