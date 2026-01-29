import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../models/trading/virtual_wallet_model.dart';
import '../models/trading/portfolio_model.dart';
import '../models/trading/transaction_model.dart';
import '../models/trading/buy_request.dart';
import '../models/trading/sell_request.dart';

/// Trading Repository
class TradingRepository {
  final DioClient _dioClient;

  TradingRepository({required DioClient dioClient}) : _dioClient = dioClient;

  /// Get virtual wallet
  Future<VirtualWalletModel> getWallet() async {
    try {
      final response = await _dioClient.get(ApiConstants.virtualWallet);
      return VirtualWalletModel.fromJson(response.data['wallet']);
    } on DioException catch (e) {
      if (e.error is ServerException) {
        throw e.error as ServerException;
      }
      throw ServerException(message: 'Failed to load wallet');
    }
  }

  /// Get portfolio
  Future<PortfolioModel> getPortfolio() async {
    try {
      final response = await _dioClient.get(ApiConstants.portfolio);
      return PortfolioModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.error is ServerException) {
        throw e.error as ServerException;
      }
      throw ServerException(message: 'Failed to load portfolio');
    }
  }

  /// Buy stock
  Future<Map<String, dynamic>> buyStock(BuyRequest request) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.buyStock,
        data: request.toJson(),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.error is ServerException) {
        throw e.error as ServerException;
      }
      throw ServerException(message: 'Failed to buy stock');
    }
  }

  /// Sell stock
  Future<Map<String, dynamic>> sellStock(SellRequest request) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.sellStock,
        data: request.toJson(),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.error is ServerException) {
        throw e.error as ServerException;
      }
      throw ServerException(message: 'Failed to sell stock');
    }
  }

  /// Get transaction history
  Future<List<TransactionModel>> getTransactions({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.transactions,
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      final transactions = (response.data['transactions'] as List<dynamic>)
          .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
          .toList();
      
      return transactions;
    } on DioException catch (e) {
      if (e.error is ServerException) {
        throw e.error as ServerException;
      }
      throw ServerException(message: 'Failed to load transactions');
    }
  }
}
