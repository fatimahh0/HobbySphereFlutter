class AuthResult {
  final String token;       // JWT ('' if missing)
  final String role;        // 'user' | 'business'
  final int businessId;     // business id if role=business else 0
  final int statusCode;     // backend status if available
  final String? message;    // optional message
  final String? error;      // optional error

  const AuthResult({
    required this.token,
    required this.role,
    required this.businessId,
    required this.statusCode,
    this.message,
    this.error,
  });

  bool get ok => token.isNotEmpty && (error == null || error!.isEmpty);
}
