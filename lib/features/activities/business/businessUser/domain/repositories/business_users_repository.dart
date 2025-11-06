import '../entities/business_user.dart';

abstract class BusinessUsersRepository {
  Future<List<BusinessUser>> getBusinessUsers(String token);

  Future<BusinessUser> createBusinessUser(
    String token, {
    required String firstname,
    required String lastname,
    String? email,
    String? phoneNumber,
  });

  Future<Map<String, dynamic>> bookCash(
    String token, {
    required int itemId,
    required int businessUserId,
    required int participants,
    required bool wasPaid,
  });
}
