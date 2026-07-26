import 'package:intl/intl.dart';

extension DateTimeFormatting on DateTime {
  String get formatted => DateFormat('yyyy-MM-dd HH:mm').format(this);
  String get formattedDate => DateFormat('yyyy-MM-dd').format(this);
  String get formattedTime => DateFormat('HH:mm').format(this);
  String get formattedShort => DateFormat('MMM dd, yyyy').format(this);
}

extension NumberFormatting on num {
  String get currency => NumberFormat('#,##0.00').format(this);
  String get compact => NumberFormat.compact().format(this);
  String get percentage => '$this%';
}

extension StringCapitalize on String {
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String get titleCase {
    return split(' ').map((word) => word.capitalize).join(' ');
  }
}
