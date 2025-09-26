class LoginState {
  final int roleIndex; // 0 user / 1 business
  final bool usePhone;
  final String email;
  final String phoneE164;
  final String password;
  final bool loading;
  final String? error;
  final String? info;
  final bool showReactivate;
  final int reactivateId;
  final String reactivateRole;
  final String token;
  final int businessId;

  // NEW: onboarding flags for Google first-time users
  final bool needsOnboarding;
  final int onboardUserId;

  const LoginState({
    this.roleIndex = 0,
    this.usePhone = true,
    this.email = '',
    this.phoneE164 = '',
    this.password = '',
    this.loading = false,
    this.error,
    this.info,
    this.showReactivate = false,
    this.reactivateId = 0,
    this.reactivateRole = 'user',
    this.token = '',
    this.businessId = 0,
    this.needsOnboarding = false, // NEW
    this.onboardUserId = 0, // NEW
  });

  LoginState copyWith({
    int? roleIndex,
    bool? usePhone,
    String? email,
    String? phoneE164,
    String? password,
    bool? loading,
    String? error,
    String? info,
    bool? showReactivate,
    int? reactivateId,
    String? reactivateRole,
    String? token,
    int? businessId,
    bool? needsOnboarding, // NEW
    int? onboardUserId, // NEW
  }) {
    return LoginState(
      roleIndex: roleIndex ?? this.roleIndex,
      usePhone: usePhone ?? this.usePhone,
      email: email ?? this.email,
      phoneE164: phoneE164 ?? this.phoneE164,
      password: password ?? this.password,
      loading: loading ?? this.loading,
      error: error,
      info: info,
      showReactivate: showReactivate ?? this.showReactivate,
      reactivateId: reactivateId ?? this.reactivateId,
      reactivateRole: reactivateRole ?? this.reactivateRole,
      token: token ?? this.token,
      businessId: businessId ?? this.businessId,
      needsOnboarding: needsOnboarding ?? this.needsOnboarding,
      onboardUserId: onboardUserId ?? this.onboardUserId,
    );
  }
}
