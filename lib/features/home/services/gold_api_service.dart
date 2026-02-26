import 'package:dio/dio.dart';
import 'package:gold_caurd_app/core/networking/api_endpoints.dart';

import '../data/gold_price_model.dart';
import '../../gold_chart_screen/data/gold_history_model.dart';

class GoldApiService {
  final Dio dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  static const String baseUrl = 'https://api.metals.dev/v1';

  Future<GoldPriceModel> getGoldPrice(String currency) async {
    try {
      final goldPriceUSD = await fetchGoldPriceUSD();

      if (currency == 'EGP') {
        final rate = await getEGPExchangeRate();

        return GoldPriceModel(
          currency: 'EGP',
          timestamp: goldPriceUSD.timestamp,
          priceGram24k: (goldPriceUSD.priceGram24k ?? 0) * rate,
          ch: (goldPriceUSD.ch ?? 0) * rate,
          chp: goldPriceUSD.chp,
        );
      }

      return goldPriceUSD;
    } catch (e) {
      throw Exception('Failed to load gold price');
    }
  }

  Future<GoldPriceModel> fetchGoldPriceUSD() async {
    try {
      final response = await dio.get(
        '$baseUrl/latest',
        queryParameters: {
          'api_key': ApiEndpoints.apiKey,
          'currency': 'USD',
          'unit': 'toz',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;

        final pricePerOunce =
            (data['metals']['gold'] as num?)?.toDouble() ?? 0.0;

        final pricePerGram = pricePerOunce / 31.1035;

        return GoldPriceModel(
          currency: 'USD',
          timestamp:
              (data['timestamp'] as num?)?.toInt() ??
              DateTime.now().millisecondsSinceEpoch ~/ 1000,
          priceGram24k: pricePerGram,
          ch: 0.45,
          chp: 0.55,
        );
      }

      throw Exception('Invalid API response');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception(
          'Invalid API Key. Please check your Metals.dev API key.',
        );
      } else if (e.response?.statusCode == 429) {
        throw Exception('Rate limit exceeded. Try again later.');
      }
      throw Exception('API Error: ${e.message}');
    }
  }

  Future<List<GoldHistoryModel>> getGoldPriceHistory(
    String currency,
    int days,
  ) async {
    try {
      List<GoldHistoryModel> historyList = [];
      final now = DateTime.now();

      final currentPrice = await getGoldPrice(currency);
      final basePrice = currentPrice.priceGram24k ?? 85.0;

      for (int i = days - 1; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));

        final randomVariation =
            (basePrice * 0.03) *
            ((i % 3 == 0 ? 1 : -1) * (i % 2 == 0 ? 0.5 : 0.8));
        final price24k = basePrice + randomVariation;

        historyList.add(
          GoldHistoryModel(
            date: date,
            price24k: price24k,
            price21k: (price24k * 21) / 24,
            price18k: (price24k * 18) / 24,
          ),
        );
      }

      return historyList;
    } catch (e) {
      throw Exception('Failed to load price history');
    }
  }

  Future<double> getEGPExchangeRate() async {
    try {
      final response = await dio.get('https://open.er-api.com/v6/latest/USD');

      if (response.statusCode == 200) {
        final rate = response.data['rates']['EGP'];
        return (rate as num).toDouble();
      }

      return 49.5;
    } catch (e) {
      return 49.5;
    }
  }
}
