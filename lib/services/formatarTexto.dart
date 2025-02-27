import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; // Adicione esta dependência no pubspec.yaml

class CapitalizeWordsInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    final capitalized = text
        .split(' ')
        .map((word) => toBeginningOfSentenceCase(word))
        .join(' ');
    return newValue.copyWith(
      text: capitalized,
      selection: newValue.selection,
    );
  }
}
