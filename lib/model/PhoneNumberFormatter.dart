import 'package:flutter/services.dart';

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    // Remove all non-digit characters
    String cleaned = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleaned.length > 10) {
      cleaned = cleaned.substring(0, 10); // Limit to 10 digits
    }

    String formatted = '';
    if (cleaned.isNotEmpty) {
      formatted = '(${cleaned.substring(0, 3)})';
      if (cleaned.length > 3) {
        formatted += ' ${cleaned.substring(3, 6)}';
      }
      if (cleaned.length > 6) {
        formatted += '-${cleaned.substring(6)}';
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
