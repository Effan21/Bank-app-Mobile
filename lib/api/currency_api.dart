import 'dart:convert';

import 'package:bank_app/model/currency_model.dart';
import 'package:http/http.dart' as http;

class Api {
  const Api();

  final String apiKey = '4WcfQXpcIE4Al0b4zXbNF3XTOmW6sUbIB0exxE1P';

  Future<List<CurrencyModel>> fetchCurrency(String? value) async {
    final response = await http.get(Uri.parse(
        'https://api.currencyapi.com/v3/latest?apikey=$apiKey&base_currency=$value'));
    var data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      List<CurrencyModel> currencies = [];
      for (var code in data["data"].keys) {
        CurrencyModel currency = CurrencyModel(
            code: data["data"][code]["code"],
            value: data["data"][code]["value"].toDouble());
        currencies.add(currency);
      }
      return currencies;
    } else {
      throw Exception('Failed');
    }
  }

  Future<CurrencyModel> fetchExchangeRate(
      String? baseValue, String? targetValue) async {
    final response = await http.get(Uri.parse(
        'https://api.currencyapi.com/v3/latest?apikey=$apiKey&base_currency=$baseValue&currencies=$targetValue'));
    var data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      CurrencyModel currency = CurrencyModel(
          code: data["data"][targetValue]["code"],
          value: data["data"][targetValue]["value"].toDouble());
      return currency;
    } else {
      throw Exception('Failed');
    }
  }
}
