import '../../domain/entities/currency.dart';
import '../../domain/repositories/currency_repository.dart';
import '../models/currency_model.dart';
import '../services/currency_service.dart';

class CurrencyRepositoryImpl implements CurrencyRepository {
  final CurrencyService service;
  CurrencyRepositoryImpl(this.service);

  @override
  Future<Currency> getCurrentCurrency(String token) async {
    // Service returns a plain string like "CAD"
    final code = await service.getCurrentCurrency(token);
    return CurrencyModel.fromServer(code).toEntity();
  }
}
