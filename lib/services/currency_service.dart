import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/currency.dart';

class CurrencyService {
  final Dio _dio = Dio();
  late final String _baseUrl;

  CurrencyService() {
    final apiKey = dotenv.env['API_KEY'] ?? '';
    _baseUrl = 'https://v6.exchangerate-api.com/v6/$apiKey';
  }

  Future<Map<String, Currency>> fetchCurrencies() async {
    try {
      final response = await _dio.get('$_baseUrl/latest/USD');
      final Map<String, dynamic> rates = response.data['conversion_rates'];

      return rates.map((key, value) => MapEntry(
            key,
            Currency(
              code: key,
              name: getCurrencyName(key),
              rate: value.toDouble(),
            ),
          ));
    } catch (e) {
      throw Exception('Failed to fetch currencies: $e');
    }
  }

  String getCurrencyName(String code) {
    final Map<String, String> currencyNames = {
      'USD': 'US Dollar',
      'EUR': 'Euro',
      'GBP': 'British Pound',
      'RUB': 'Russian Ruble',
      'JPY': 'Japanese Yen',
      'CNY': 'Chinese Yuan',
      'AUD': 'Australian Dollar',
      'CAD': 'Canadian Dollar',
      'CHF': 'Swiss Franc',
      'HKD': 'Hong Kong Dollar',
      'NZD': 'New Zealand Dollar',
      'SEK': 'Swedish Krona',
      'KRW': 'South Korean Won',
      'SGD': 'Singapore Dollar',
      'NOK': 'Norwegian Krone',
      'MXN': 'Mexican Peso',
      'INR': 'Indian Rupee',
      'BRL': 'Brazilian Real',
      'ZAR': 'South African Rand',
      'TRY': 'Turkish Lira',
    };
    return currencyNames[code] ?? code;
  }
}
