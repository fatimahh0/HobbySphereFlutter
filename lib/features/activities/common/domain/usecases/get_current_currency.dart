// lib/features/activities/common/domain/usecases/get_current_currency.dart
import '../entities/currency.dart';
import '../repositories/currency_repository.dart';

class GetCurrentCurrency {
  final CurrencyRepository repository;
  GetCurrentCurrency(this.repository);

  Future<Currency> call(String token) {
    return repository.getCurrentCurrency(token);
  }
}
