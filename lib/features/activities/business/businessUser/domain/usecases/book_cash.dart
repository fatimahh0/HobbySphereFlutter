import '../repositories/business_users_repository.dart';

/// Use case: manually book an existing BusinessUser into an activity (cash flow).
class BookCash {
  final BusinessUsersRepository repo;

  BookCash(this.repo);

  /// Executes the booking request
  /// - [token]: authorization token
  /// - [itemId]: activity/item ID
  /// - [businessUserId]: client user ID
  /// - [participants]: number of participants
  /// - [wasPaid]: true if paid in cash
  Future<Map<String, dynamic>> call(
    String token, {
    required int itemId,
    required int businessUserId,
    required int participants,
    required bool wasPaid,
  }) {
    return repo.bookCash(
      token,
      itemId: itemId,
      businessUserId: businessUserId,
      participants: participants,
      wasPaid: wasPaid,
    );
  }
}
