/// Simple result object shared by use cases.
/// Updated to support Google first-time users (isNewUser + userId).
class AuthResult {
  final String token; // final JWT (normal login) or temp when INACTIVE
  final String role; // 'user' or 'business'
  final int businessId; // business id for business role, else 0
  final int subjectId; // user.id or business.id (needed for reactivate)
  final bool wasInactive; // server says account is INACTIVE

  // NEW: for Google first-time sign-in flow
  final bool isNewUser; // backend says this is a newly created user
  final int userId; // user id (for adding interests)

  final String? message; // optional message from server
  final String? error; // optional error from server

  const AuthResult({
    required this.token,
    required this.role,
    required this.businessId,
    required this.subjectId,
    required this.wasInactive,
    this.isNewUser = false, // NEW default
    this.userId = 0, // NEW default
    this.message,
    this.error,
  });

  bool get ok => (token.isNotEmpty) || wasInactive;
}
