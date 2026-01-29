import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../models/stock/company_model.dart';
import '../models/stock/stock_price_model.dart';
import '../models/stock/market_overview_model.dart';
import '../models/stock/price_history_model.dart';
import '../models/stock/stock_event_model.dart';

/// Stock Repository
class StockRepository {
  final DioClient _dioClient;

  StockRepository({required DioClient dioClient}) : _dioClient = dioClient;

  /// Get all companies with pagination
  Future<List<CompanyModel>> getCompanies({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.stocks,
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      final companies = (response.data['companies'] as List<dynamic>)
          .map((e) => CompanyModel.fromJson(e as Map<String, dynamic>))
          .toList();
      
      return companies;
    } on DioException catch (e) {
      if (e.error is ServerException) {
        throw e.error as ServerException;
      }
      throw ServerException(message: 'Failed to load companies');
    }
  }

  /// Search companies
  Future<List<CompanyModel>> searchCompanies(String query) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.searchStocks,
        queryParameters: {'q': query},
      );

      final companies = (response.data['companies'] as List<dynamic>)
          .map((e) => CompanyModel.fromJson(e as Map<String, dynamic>))
          .toList();
      
      return companies;
    } on DioException catch (e) {
      if (e.error is ServerException) {
        throw e.error as ServerException;
      }
      throw ServerException(message: 'Search failed');
    }
  }

  /// Get companies by sector
  Future<List<CompanyModel>> getCompaniesBySector(
    String sector, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.sectorStocks(sector),
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      final companies = (response.data['companies'] as List<dynamic>)
          .map((e) => CompanyModel.fromJson(e as Map<String, dynamic>))
          .toList();
      
      return companies;
    } on DioException catch (e) {
      if (e.error is ServerException) {
        throw e.error as ServerException;
      }
      throw ServerException(message: 'Failed to load sector companies');
    }
  }

  /// Get company details
  Future<CompanyModel> getCompanyDetails(String symbol) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.stockDetail(symbol),
      );

      return CompanyModel.fromJson(response.data['company']);
    } on DioException catch (e) {
      if (e.error is ServerException) {
        throw e.error as ServerException;
      }
      throw ServerException(message: 'Failed to load company details');
    }
  }

  /// Get current stock price
  Future<StockPriceModel> getCurrentPrice(String symbol) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.stockPrice(symbol),
      );

      return StockPriceModel.fromJson(response.data['price']);
    } on DioException catch (e) {
      if (e.error is ServerException) {
        throw e.error as ServerException;
      }
      throw ServerException(message: 'Failed to load stock price');
    }
  }

  /// Get price history
  Future<PriceHistoryModel> getPriceHistory(
    String symbol, {
    String timeframe = '1d',
    int days = 30,
  }) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.stockHistory(symbol),
        queryParameters: {
          'timeframe': timeframe,
          'days': days,
        },
      );

      return PriceHistoryModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.error is ServerException) {
        throw e.error as ServerException;
      }
      throw ServerException(message: 'Failed to load price history');
    }
  }

  /// Get market overview
  Future<MarketOverviewModel> getMarketOverview() async {
    try {
      final response = await _dioClient.get(ApiConstants.marketOverview);
      return MarketOverviewModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.error is ServerException) {
        throw e.error as ServerException;
      }
      throw ServerException(message: 'Failed to load market overview');
    }
  }

  /// Get top gainers
  Future<List<TopGainerLoser>> getTopGainers({int limit = 10}) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.topGainers,
        queryParameters: {'limit': limit},
      );

      final gainers = (response.data['gainers'] as List<dynamic>)
          .map((e) => TopGainerLoser.fromJson(e as Map<String, dynamic>))
          .toList();
      
      return gainers;
    } on DioException catch (e) {
      if (e.error is ServerException) {
        throw e.error as ServerException;
      }
      throw ServerException(message: 'Failed to load top gainers');
    }
  }

  /// Get top losers
  Future<List<TopGainerLoser>> getTopLosers({int limit = 10}) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.topLosers,
        queryParameters: {'limit': limit},
      );

      final losers = (response.data['losers'] as List<dynamic>)
          .map((e) => TopGainerLoser.fromJson(e as Map<String, dynamic>))
          .toList();
      
      return losers;
    } on DioException catch (e) {
      if (e.error is ServerException) {
        throw e.error as ServerException;
      }
      throw ServerException(message: 'Failed to load top losers');
    }
  }

  /// Get most active stocks
  Future<List<CompanyModel>> getMostActive({int limit = 10}) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.mostActive,
        queryParameters: {'limit': limit},
      );

      final active = (response.data['active'] as List<dynamic>)
          .map((e) => CompanyModel.fromJson(e as Map<String, dynamic>))
          .toList();
      
      return active;
    } on DioException catch (e) {
      if (e.error is ServerException) {
        throw e.error as ServerException;
      }
      throw ServerException(message: 'Failed to load most active stocks');
    }
  }

  /// Get stock events
  Future<List<StockEventModel>> getStockEvents(String symbol) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.stockEvents(symbol),
      );

      final events = (response.data['events'] as List<dynamic>)
          .map((e) => StockEventModel.fromJson(e as Map<String, dynamic>))
          .toList();
      
      return events;
    } on DioException catch (e) {
      if (e.error is ServerException) {
        throw e.error as ServerException;
      }
      throw ServerException(message: 'Failed to load stock events');
    }
  }
}
