import '../entities/currency.dart';

// Abstract repo: defines what app needs from data source
abstract class CurrencyRepository {
  Future<Currency> getCurrentCurrency(String token);
}
