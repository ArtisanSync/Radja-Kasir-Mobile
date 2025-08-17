import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyFormat {
  static String convertToIdr(dynamic number, int decimalDigit) {
    if (number == null) return 'Rp 0';
    
    NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: decimalDigit,
    );
    return currencyFormatter.format(number);
  }

  static String formatCurrency(dynamic value) {
    if (value == null) return 'Rp 0';
    
    double amount;
    if (value is String) {
      amount = double.tryParse(value.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
    } else if (value is int) {
      amount = value.toDouble();
    } else if (value is double) {
      amount = value;
    } else {
      return 'Rp 0';
    }
    
    return convertToIdr(amount, 0);
  }

  // Format compact untuk angka besar (1K, 1M, dll)
  static String convertToCompactIdr(dynamic number) {
    if (number == null) return 'Rp 0';
    
    final value = number is String ? double.tryParse(number) ?? 0 : number.toDouble();
    
    if (value >= 1000000000) {
      return 'Rp ${(value / 1000000000).toStringAsFixed(1)}M';
    } else if (value >= 1000000) {
      return 'Rp ${(value / 1000000).toStringAsFixed(1)}Jt';
    } else if (value >= 1000) {
      return 'Rp ${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return 'Rp ${value.toStringAsFixed(0)}';
    }
  }

  static String formatCurrencyInput(String value) {
    if (value.isEmpty) return '';
    
    String digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.isEmpty) return '';
    
    int number = int.parse(digitsOnly);
    NumberFormat formatter = NumberFormat('#,###', 'id_ID');
    return formatter.format(number);
  }

  static String formatCurrencyInputFromInt(int value) {
    if (value <= 0) return '';
    NumberFormat formatter = NumberFormat('#,###', 'id_ID');
    return formatter.format(value);
  }

  static double parseCurrency(String value) {
    if (value.isEmpty) return 0;
    String digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    return double.tryParse(digitsOnly) ?? 0;
  }

  static String formatPrice(dynamic price) {
    if (price == null) return 'Rp 0';
    
    final value = price is String ? double.tryParse(price) ?? 0 : price.toDouble();
    return convertToIdr(value, 0);
  }

  // Format untuk diskon
  static String formatDiscount(dynamic discount, {bool isPercentage = false}) {
    if (discount == null) return '';
    
    if (isPercentage) {
      return '$discount%';
    } else {
      return convertToIdr(discount, 0);
    }
  }

  static String formatNumber(dynamic value) {
    if (value == null) return '0';
    
    double amount;
    if (value is String) {
      amount = double.tryParse(value) ?? 0;
    } else if (value is int) {
      amount = value.toDouble();
    } else if (value is double) {
      amount = value;
    } else {
      return '0';
    }
    
    final formatter = NumberFormat('#,###', 'id_ID');
    return formatter.format(amount);
  }
}

// Currency Input Formatter untuk TextField
class CurrencyInputFormatter extends TextInputFormatter {
  final bool withSymbol;

  CurrencyInputFormatter({this.withSymbol = true});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.isEmpty) {
      return const TextEditingValue();
    }

    String formatted = CurrencyFormat.formatCurrencyInput(digitsOnly);
    if (withSymbol) {
      formatted = 'Rp $formatted';
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class PriceInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.isEmpty) {
      return const TextEditingValue();
    }

    String formatted = CurrencyFormat.formatCurrencyInput(digitsOnly);
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
