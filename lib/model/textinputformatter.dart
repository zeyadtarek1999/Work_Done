import 'package:flutter/services.dart';


class EnglishTextInputFormatter extends TextInputFormatter {
  // Regular expression to match English letters, numbers, and special characters (allowing empty string)
  final RegExp _englishRegExp = RegExp(r'^[a-zA-Z0-9!@#$%^&*(),.?":{}|<>]*$');

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Check if the entered text matches the updated English regular expression
    if (_englishRegExp.hasMatch(newValue.text)) {
      return newValue; // If it matches, allow the input
    } else {
      // If it doesn't match, revert to the previous value (don't allow the input)
      return oldValue;
    }
  }
}
