import '../../domain/entities/currency.dart';

class CurrencyModel {
  final String code; // e.g. "CAD"
  final String? symbol; // optional

  CurrencyModel({required this.code, this.symbol});

  // Old shape: JSON map from server
  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    final code =
        (json['currencyType'] ?? json['code'] ?? json['currency'] ?? 'CAD')
            .toString();
    return CurrencyModel(code: code, symbol: json['symbol']?.toString());
  }

  // New shape: plain string from server
  factory CurrencyModel.fromCode(String code) => CurrencyModel(code: code);

  // Helper that handles both cases
  factory CurrencyModel.fromServer(dynamic payload) {
    if (payload is String) return CurrencyModel.fromCode(payload);
    if (payload is Map<String, dynamic>) return CurrencyModel.fromJson(payload);
    throw ArgumentError(
      'Unsupported currency payload type: ${payload.runtimeType}',
    );
  }

  Currency toEntity() => Currency(code: code, symbol: symbol);
}
