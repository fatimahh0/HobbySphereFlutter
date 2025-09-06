// lib/features/activities/common/domain/entities/currency.dart
class Currency {
  final String code; // "CAD"
  final String? symbol; // optional, may be null

  const Currency({required this.code, this.symbol});
}
