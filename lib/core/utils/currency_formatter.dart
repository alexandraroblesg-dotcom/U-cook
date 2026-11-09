import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _copFormatter = NumberFormat.currency(
    locale: 'es_CO',
    symbol: r'$ ',
    decimalDigits: 0,
  );

  /// Formatea montos en pesos colombianos sin decimales, ej: "$ 300.000"
  static String formatCOP(int amount) {
    return _copFormatter.format(amount);
  }

  /// Limpia un string de entrada y extrae solo digitos enteros
  static int parseCOP(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^\d]'), '');
    return int.tryParse(cleaned) ?? 0;
  }
}
