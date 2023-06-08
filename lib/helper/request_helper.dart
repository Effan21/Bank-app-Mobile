import 'package:bank_app/api/currency_api.dart';
import 'package:bank_app/model/currency_model.dart';

class RequestHelper {
  Api api = Api();

  Future<List<CurrencyModel>> getCurrencies(String? value) {
    return api.fetchCurrency(value);
  }

  Future<CurrencyModel> getExchangeRate(String? baseValue, String targetValue) {
    return api.fetchExchangeRate(baseValue, targetValue);
  }
}