import 'dart:convert';

import 'package:flutter/services.dart';

class Utf8LengthLimitingTextInputFormatter extends TextInputFormatter {
  final int maxBytes;

  const Utf8LengthLimitingTextInputFormatter(this.maxBytes);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (maxBytes <= 0) return oldValue;
    final bytes = utf8.encode(newValue.text);
    if (bytes.length <= maxBytes) return newValue;

    final truncated = _truncateToMaxBytes(newValue.text, maxBytes);
    return TextEditingValue(
      text: truncated,
      selection: TextSelection.collapsed(offset: truncated.length),
      composing: TextRange.empty,
    );
  }

  String _truncateToMaxBytes(String text, int limit) {
    final buffer = StringBuffer();
    var used = 0;
    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      final charBytes = utf8.encode(char).length;
      if (used + charBytes > limit) break;
      buffer.write(char);
      used += charBytes;
    }
    return buffer.toString();
  }
}
