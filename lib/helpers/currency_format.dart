import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyFormat {
  static String convertToIdr(dynamic number, int decimalDigit) {
    NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: decimalDigit,
    );
    return currencyFormatter.format(number);
  }

  // Format input untuk currency
  static String formatCurrencyInput(String value) {
    if (value.isEmpty) return '';
    
    // Remove semua karakter non-digit
    String digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.isEmpty) return '';
    
    // Convert to number
    int number = int.parse(digitsOnly);
    
    // Format dengan NumberFormat
    NumberFormat formatter = NumberFormat('#,###', 'id_ID');
    return formatter.format(number);
  }

  // Parse currency string ke number
  static double parseCurrency(String value) {
    if (value.isEmpty) return 0;
    String digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    return double.tryParse(digitsOnly) ?? 0;
  }
}

// Currency Input Formatter
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove semua karakter non-digit
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.isEmpty) {
      return const TextEditingValue();
    }

    // Format dengan currency
    String formatted = CurrencyFormat.formatCurrencyInput(digitsOnly);
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
