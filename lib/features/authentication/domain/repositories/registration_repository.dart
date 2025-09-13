import 'package:image_picker/image_picker.dart';
import '../entities/user_profile.dart';
import '../entities/business_profile.dart';

abstract class RegistrationRepository {
  // user
  Future<void> sendUserVerification({
    String? email,
    String? phone,
    required String password,
  });
  Future<int> verifyUserEmailCode(String email, String code);
  Future<int> verifyUserPhoneCode(String phone, String code);
  Future<UserProfile> completeUserProfile({
    required int pendingId,
    required String username,
    required String firstName,
    required String lastName,
    required bool isPublic,
    XFile? image,
  });
  Future<void> addUserInterests(int userId, List<int> ids);
  Future<void> resendUserCode(String contact);

  // business
  Future<int> sendBusinessVerification({
    String? email,
    String? phone,
    required String password,
  });
  Future<int> verifyBusinessEmailCode(String email, String code);
  Future<int> verifyBusinessPhoneCode(String phone, String code);
  Future<BusinessProfile> completeBusinessProfile({
    required int pendingId,
    required String name,
    String? description,
    String? websiteUrl,
    XFile? logo,
    XFile? banner,
  });
  Future<void> resendBusinessCode(String contact);
}
