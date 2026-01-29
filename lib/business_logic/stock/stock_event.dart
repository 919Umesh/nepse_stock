import 'package:equatable/equatable.dart';

/// Stock Events
abstract class StockEvent extends Equatable {
  const StockEvent();

  @override
  List<Object?> get props => [];
}

/// Load companies (Paginated)
class LoadCompanies extends StockEvent {
  final int limit;
  final int offset;
  final bool isRefresh;

  const LoadCompanies({
    this.limit = 50, 
    this.offset = 0,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [limit, offset, isRefresh];
}

/// Search companies
class SearchCompanies extends StockEvent {
  final String query;

  const SearchCompanies({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Load companies by sector (Paginated)
class LoadCompaniesBySector extends StockEvent {
  final String sector;
  final int limit;
  final int offset;
  final bool isRefresh;

  const LoadCompaniesBySector({
    required this.sector,
    this.limit = 50,
    this.offset = 0,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [sector, limit, offset, isRefresh];
}

/// Load company details
class LoadCompanyDetails extends StockEvent {
  final String symbol;

  const LoadCompanyDetails({required this.symbol});

  @override
  List<Object?> get props => [symbol];
}

/// Load stock price
class LoadStockPrice extends StockEvent {
  final String symbol;

  const LoadStockPrice({required this.symbol});

  @override
  List<Object?> get props => [symbol];
}

/// Load price history
class LoadPriceHistory extends StockEvent {
  final String symbol;
  final String timeframe;
  final int days;

  const LoadPriceHistory({
    required this.symbol,
    this.timeframe = '1d',
    this.days = 30,
  });

  @override
  List<Object?> get props => [symbol, timeframe, days];
}

/// Load market overview
class LoadMarketOverview extends StockEvent {
  const LoadMarketOverview();
}

/// Load top gainers
class LoadTopGainers extends StockEvent {
  final int limit;

  const LoadTopGainers({this.limit = 10});

  @override
  List<Object?> get props => [limit];
}

/// Load top losers
class LoadTopLosers extends StockEvent {
  final int limit;

  const LoadTopLosers({this.limit = 10});

  @override
  List<Object?> get props => [limit];
}
