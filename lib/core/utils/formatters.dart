import '../constants/app_strings.dart';

/// Formatting helpers shared by the UI.
class Formatters {
  Formatters._();

  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// `12.5` -> `$12.50`
  static String price(double value) =>
      '${AppStrings.currencySymbol}${value.toStringAsFixed(2)}';

  /// `2026-10-25 21:05` -> `25 Oct 2026, 9:05 PM`
  static String dateTime(DateTime value) {
    final local = value.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour < 12 ? 'AM' : 'PM';
    return '${local.day} ${_months[local.month - 1]} ${local.year}, '
        '$hour:$minute $period';
  }

  /// `home-decoration` -> `Home Decoration`
  static String titleCase(String value) {
    return value
        .split(RegExp(r'[-_\s]+'))
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
