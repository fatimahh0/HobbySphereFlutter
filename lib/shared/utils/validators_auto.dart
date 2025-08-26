// ===== Flutter 3.35.x =====
import 'package:email_validator/email_validator.dart'; // email format check
import 'package:phone_numbers_parser/phone_numbers_parser.dart'; // phone parsing

// Validate a phone using country rules (no manual lengths).
// national: digits the user types (no +code), dialCode: like "1" or "961".
String? validatePhoneAuto({
  required String national,
  required String dialCode,
}) {
  final digits = national.replaceAll(RegExp(r'\D'), ''); // keep digits only
  if (digits.isEmpty) return 'Required'; // must not be empty

  final e164 = '+$dialCode$digits'; // build +E.164
  try {
    final pn = PhoneNumber.parse(e164); // parse with metadata
    final ok = pn.isValid(); // ✅ v8 API: no type parameter

    return ok ? null : 'Invalid phone for selected country';
  } catch (_) {
    return 'Invalid phone for selected country';
  }
}

// Validate email; optionally restrict to whitelisted domains.
String? validateEmailAuto({
  required String? input,
  Set<String>? allowedDomains,
}) {
  final v = (input ?? '').trim().toLowerCase(); // normalize
  if (v.isEmpty) return 'Required'; // required
  if (!EmailValidator.validate(v)) return 'Invalid email'; // format check

  if (allowedDomains != null && allowedDomains.isNotEmpty) {
    final domain = v.split('@').last; // after @
    if (!allowedDomains.contains(domain)) {
      final sample = allowedDomains.take(4).join(', '); // short list
      return 'Use a supported domain ($sample)';
    }
  }
  return null; // ok
}
// ===== End Flutter 3.35.x =====