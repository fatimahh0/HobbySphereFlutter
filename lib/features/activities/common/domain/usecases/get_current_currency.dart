import '../entities/currency.dart';
import '../repositories/currency_repository.dart';

// UseCase: orchestrates fetching current currency
class GetCurrentCurrency {
  final CurrencyRepository repository;
  GetCurrentCurrency(this.repository);

  Future<Currency> call(String token) {
    return repository.getCurrentCurrency(token);
  }
}
