import 'package:flutter/services.dart';


class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    final int newTextLength = newValue.text.length;
    int selectionIndex = newValue.selection.baseOffset;

    int usedSubstringIndex = 0;
    final StringBuffer newText = StringBuffer();

    if (newTextLength >= 1) {
      newText.write('(');
      if (newValue.selection.baseOffset >= 1) selectionIndex++;
    }
    if (newTextLength >= 4) {
      newText.write(newValue.text.substring(usedSubstringIndex, 3) + ') ');
      usedSubstringIndex = 3;
      if (newValue.selection.baseOffset >= 3) selectionIndex += 2;
    }
    if (newTextLength >= 7) {
      newText.write(newValue.text.substring(usedSubstringIndex, 6) + '-');
      usedSubstringIndex = 6;
      if (newValue.selection.baseOffset >= 6) selectionIndex++;
    }
    // Dump the rest.
    if (newTextLength >= usedSubstringIndex) {
      newText.write(newValue.text.substring(usedSubstringIndex));
    }

    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}