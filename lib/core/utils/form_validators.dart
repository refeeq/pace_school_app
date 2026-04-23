/// Practical upper bound for a single email address in forms (SMTP path limit).
const int kMaxEmailLength = 254;

/// Same pattern as historically used in the app for link/email detection.
final RegExp kEmailPattern = RegExp(
  r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$',
);

bool isValidEmail(String email) {
  final t = email.trim();
  if (t.isEmpty || t.length > kMaxEmailLength) return false;
  return kEmailPattern.hasMatch(t);
}

/// Returns `null` if valid, otherwise an error message for [TextFormField.validator].
String? validateEmailField(String? value) {
  final t = value?.trim() ?? '';
  if (t.isEmpty) return 'Enter a valid email';
  if (t.length > kMaxEmailLength) return 'Email is too long';
  if (!isValidEmail(t)) return 'Enter a valid email';
  return null;
}

/// UAE mobile: digits only — `05` + 8 digits, or `5` + 8 digits, or `971` + `5` + 8 digits.
bool isValidUaMobileDigits(String digits) {
  if (digits.isEmpty) return false;
  return RegExp(r'^05[0-9]{8}$').hasMatch(digits) ||
      RegExp(r'^5[0-9]{8}$').hasMatch(digits) ||
      RegExp(r'^9715[0-9]{8}$').hasMatch(digits);
}

String? validateUaMobileField(String? value) {
  final t = value?.trim() ?? '';
  if (t.isEmpty) return 'Enter a valid mobile number';
  if (!RegExp(r'^[0-9]+$').hasMatch(t)) {
    return 'Enter digits only';
  }
  if (!isValidUaMobileDigits(t)) {
    return 'Enter a valid UAE mobile (e.g. 05XXXXXXXX or 9715XXXXXXXX)';
  }
  return null;
}
