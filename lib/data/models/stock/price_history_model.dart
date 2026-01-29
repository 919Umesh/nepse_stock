/// Price History Response Model
class PriceHistoryModel {
  final String symbol;
  final String timeframe;
  final List<PriceDataPoint> prices;

  PriceHistoryModel({
    required this.symbol,
    required this.timeframe,
    required this.prices,
  });

  factory PriceHistoryModel.fromJson(Map<String, dynamic> json) {
    return PriceHistoryModel(
      symbol: json['symbol'] as String,
      timeframe: json['timeframe'] as String,
      prices: (json['prices'] as List<dynamic>)
          .map((e) => PriceDataPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Individual price data point
class PriceDataPoint {
  final double openPrice;
  final double highPrice;
  final double lowPrice;
  final double closePrice;
  final int volume;
  final DateTime timestamp;

  PriceDataPoint({
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.closePrice,
    required this.volume,
    required this.timestamp,
  });

  factory PriceDataPoint.fromJson(Map<String, dynamic> json) {
    return PriceDataPoint(
      openPrice: (json['open_price'] as num).toDouble(),
      highPrice: (json['high_price'] as num).toDouble(),
      lowPrice: (json['low_price'] as num).toDouble(),
      closePrice: (json['close_price'] as num).toDouble(),
      volume: json['volume'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
