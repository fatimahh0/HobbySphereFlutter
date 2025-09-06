// lib/features/activities/common/data/models/currency_model.dart
import '../../domain/entities/currency.dart';

class CurrencyModel {
  final String code;
  final String? symbol;

  CurrencyModel({required this.code, this.symbol});

  // Case 1: server sends a JSON map (future-proof)
  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    final code =
        (json['currencyType'] ?? json['code'] ?? json['currency'] ?? 'CAD')
            .toString();
    return CurrencyModel(code: code, symbol: json['symbol']?.toString());
  }

  // Case 2: server sends just a plain string like "CAD"
  factory CurrencyModel.fromCode(String code) => CurrencyModel(code: code);

  // General helper: detects type automatically
  factory CurrencyModel.fromServer(dynamic payload) {
    if (payload is String) return CurrencyModel.fromCode(payload);
    if (payload is Map<String, dynamic>) return CurrencyModel.fromJson(payload);
    throw ArgumentError(
      'Unsupported currency payload type: ${payload.runtimeType}',
    );
  }

  // Convert to domain entity
  Currency toEntity() => Currency(code: code, symbol: symbol);
}
