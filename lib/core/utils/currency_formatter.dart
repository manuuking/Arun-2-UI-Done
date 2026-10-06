import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final NumberFormat _numberFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '',
    decimalDigits: 2,
  );

  static final NumberFormat _integerFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '',
    decimalDigits: 0,
  );

  static final NumberFormat _compactFormat = NumberFormat.compactCurrency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  /// Formats currency with ₹ symbol: e.g. ₹1,00,000.00 or ₹76,377.60
  static String format(double amount) {
    return _currencyFormat.format(amount);
  }

  /// Formats plain number with Indian commas without symbol: e.g. 1,00,000.00
  static String formatNumber(double amount, {int decimalDigits = 2}) {
    if (decimalDigits == 0 || (amount % 1 == 0 && decimalDigits <= 0)) {
      return _integerFormat.format(amount.round()).trim();
    }
    final fmt = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '',
      decimalDigits: decimalDigits,
    );
    return fmt.format(amount).trim();
  }

  /// Formats quantity with Indian commas: e.g. 10,000 or 4,000
  static String formatQuantity(double qty) {
    if (qty % 1 == 0) {
      return _integerFormat.format(qty.toInt()).trim();
    }
    return _numberFormat.format(qty).trim();
  }

  /// Compact shorthand: e.g. ₹42.8L, ₹6.8Cr
  static String formatCompact(double amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    }
    return _compactFormat.format(amount);
  }
}
