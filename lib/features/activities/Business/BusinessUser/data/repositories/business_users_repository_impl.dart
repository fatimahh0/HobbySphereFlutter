import '../../domain/entities/business_user.dart';
import '../../domain/repositories/business_users_repository.dart';
import '../models/business_user_model.dart';
import '../services/business_users_service.dart';

/// Implementation of [BusinessUsersRepository]
/// - Bridges the domain layer with the data layer.
/// - Uses [BusinessUsersService] to call API endpoints and
///   maps the raw JSON responses into domain entities/models.
class BusinessUsersRepositoryImpl implements BusinessUsersRepository {
  final BusinessUsersService service;

  BusinessUsersRepositoryImpl(this.service);

  /// Fetch all business users belonging to the current business
  @override
  Future<List<BusinessUser>> getBusinessUsers(String token) async {
    final data = await service.fetchUsers(token);
    return data
        .map<BusinessUser>((e) => BusinessUserModel.fromJson(e))
        .toList();
  }

  /// Create a new business user (either with email or phone number)
  @override
  Future<BusinessUser> createBusinessUser(
    String token, {
    required String firstname,
    required String lastname,
    String? email,
    String? phoneNumber,
  }) async {
    final data = await service.createUser(
      token,
      firstname: firstname,
      lastname: lastname,
      email: email,
      phoneNumber: phoneNumber,
    );
    return BusinessUserModel.fromJson(data);
  }

  /// Book Cash → manually add a booking for a BusinessUser on an activity
  /// - `itemId`: ID of the activity/item
  /// - `businessUserId`: ID of the existing business user (client)
  /// - `participants`: number of participants to register
  /// - `wasPaid`: whether the booking was already paid in cash
  @override
  Future<Map<String, dynamic>> bookCash(
    String token, {
    required int itemId,
    required int businessUserId,
    required int participants,
    required bool wasPaid,
  }) async {
    final data = await service.bookCash(
      token: token,
      itemId: itemId,
      businessUserId: businessUserId,
      participants: participants,
      wasPaid: wasPaid,
    );
    return data;
  }
}
