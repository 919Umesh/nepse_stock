import 'package:equatable/equatable.dart';

/// Trading Events
abstract class TradingEvent extends Equatable {
  const TradingEvent();

  @override
  List<Object?> get props => [];
}

/// Buy stock
class BuyStockRequested extends TradingEvent {
  final String symbol;
  final int quantity;

  const BuyStockRequested({
    required this.symbol,
    required this. quantity,
  });

  @override
  List<Object?> get props => [symbol, quantity];
}

/// Sell stock
class SellStockRequested extends TradingEvent {
  final String symbol;
  final int quantity;

  const SellStockRequested({
    required this.symbol,
    required this.quantity,
  });

  @override
  List<Object?> get props => [symbol, quantity];
}

/// Load transaction history
class LoadTransactions extends TradingEvent {
  final int limit;
  final int offset;

  const LoadTransactions({this.limit = 50, this.offset = 0});

  @override
  List<Object?> get props => [limit, offset];
}
