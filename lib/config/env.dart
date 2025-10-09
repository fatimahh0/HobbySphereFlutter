class Env {
  // Prefer passing via --dart-define=API_BASE_URL=...
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL', // e.g. http://3.96.140.126:8080
    defaultValue: '', // empty means "not provided"
  );

  static const locationIqKey = String.fromEnvironment(
    'LOCATIONIQ_KEY',
    defaultValue: 'pk.14ea0e02d4685f88a3ec5ea23dd898b9',
  );

  static const stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue:
        'pk_test_51RnLY8ROH9W55MgTYuuYpaStORtbLEggQMGOYxzYacMiDUpbfifBgThEzcMgFnvyMaskalQ0WUcQv08aByizug1I00Wcq3XHll',
  );

  // Optional role if you want to switch shells/tabs via flag
  static const appRole = String.fromEnvironment(
    'APP_ROLE',
    defaultValue: 'both',
  );

  // Convenience builders (only valid if you pass LOCATIONIQ_KEY)
  static String get locationIqAutocomplete =>
      'https://api.locationiq.com/v1/autocomplete?key=$locationIqKey';
  static String get locationIqSearch =>
      'https://api.locationiq.com/v1/search?key=$locationIqKey';
  static String get locationIqReverse =>
      'https://us1.locationiq.com/v1/reverse?key=$locationIqKey';
}
