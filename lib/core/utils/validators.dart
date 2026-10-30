/// Form field validators. Each returns `null` when the value is valid.
class Validators {
  Validators._();

  static String? required(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  /// Bangladeshi mobile number: 11 digits starting with 01,
  /// optionally prefixed with +88 or 88.
  static String? bdPhone(String? value) {
    final input = value?.replaceAll(RegExp(r'[\s-]'), '') ?? '';
    if (input.isEmpty) return 'Phone number is required';
    if (!RegExp(r'^(\+?88)?01[3-9]\d{8}$').hasMatch(input)) {
      return 'Enter a valid number, e.g. 01712345678';
    }
    return null;
  }

  static String? postalCode(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return 'Postal code is required';
    if (!RegExp(r'^\d{4,6}$').hasMatch(input)) return 'Use 4 to 6 digits';
    return null;
  }
}
