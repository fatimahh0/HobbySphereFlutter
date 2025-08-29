// Utils: formatters, colors, URL resolver, shared decoration.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String currencySymbol(String code) {
  switch (code.toUpperCase()) {
    case 'DOLLAR':
      return r'$';
    case 'EURO':
      return '€';
    case 'CAD':
      return 'C\$';
    default:
      return code;
  }
}

String fmtDate(DateTime? d) => d == null ? 'N/A' : DateFormat.yMd().format(d);
String fmtPrice(num v) => NumberFormat('#,##0.##').format(v);

String? resolveImage(String? serverRoot, String? raw) {
  if (raw == null || raw.isEmpty) return null;
  if (raw.startsWith('http')) return raw;
  if (serverRoot == null || serverRoot.isEmpty) return raw;
  final root = serverRoot.endsWith('/')
      ? serverRoot.substring(0, serverRoot.length - 1)
      : serverRoot;
  final path = raw.startsWith('/') ? raw : '/$raw';
  return '$root$path';
}

Color statusColor(BuildContext ctx, String status) {
  final s = status.toLowerCase();
  if (s.contains('upcoming') || s.contains('active')) return Colors.green;
  if (s.contains('terminated') || s.contains('canceled')) {
    return Theme.of(ctx).colorScheme.error;
  }
  return const Color(0xFF9CA3AF);
}

BoxDecoration cardDecoration(ColorScheme cs) => BoxDecoration(
  color: cs.surface,
  borderRadius: BorderRadius.circular(16),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 14,
      offset: const Offset(0, 8),
    ),
  ],
);
