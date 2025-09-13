// Simple result object shared by use cases.
class AuthResult {
  final String token; // final JWT (normal login) or temp when INACTIVE
  final String role; // 'user' or 'business'
  final int businessId; // business id for business role, else 0
  final int subjectId; // user.id or business.id (needed for reactivate)
  final bool wasInactive; // server says account is INACTIVE
  final String? message; // optional message from server
  final String? error; // optional error from server

  const AuthResult({
    required this.token, // token string (may be temp if wasInactive)
    required this.role, // role string
    required this.businessId, // business id or 0
    required this.subjectId, // id to reactivate
    required this.wasInactive, // need reactivation?
    this.message, // info
    this.error, // error
  });

  bool get ok => // success when token exists OR we need reactivation
      (token.isNotEmpty) || wasInactive;
}
