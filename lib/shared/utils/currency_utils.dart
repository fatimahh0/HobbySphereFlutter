// lib/shared/utils/currency_util.dart
String currencySymbol(String? raw) {
  final c = (raw ?? '').trim().toUpperCase();
  switch (c) {
    case 'USD':
      return r'$';
    case 'EUR':
    case 'EURO':
      return '€';
    case 'CAD':
      return 'C\$';
    case 'LBP':
    case 'L.L':
      return 'ل.ل';
    default:
      // fallback: show the code if unknown (e.g., "GBP")
      return c;
  }
}

String formatPrice(num? price, String? rawCode) {
  if (price == null) return '';
  final v = price % 1 == 0
      ? price.toInt().toString()
      : price.toStringAsFixed(2);
  final sym = currencySymbol(rawCode);
  return sym.isEmpty ? v : '$sym$v';
}
