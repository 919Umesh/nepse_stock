import 'package:equatable/equatable.dart';

/// Stock Price Model
class StockPriceModel extends Equatable {
  final int id;
  final int companyId;
  final double openPrice;
  final double highPrice;
  final double lowPrice;
  final double closePrice;
  final int volume;
  final DateTime timestamp;
  final String timeframe;

  const StockPriceModel({
    required this.id,
    required this.companyId,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.closePrice,
    required this.volume,
    required this.timestamp,
    required this.timeframe,
  });

  factory StockPriceModel.fromJson(Map<String, dynamic> json) {
    return StockPriceModel(
      id: json['id'] as int,
      companyId: json['company_id'] as int,
      openPrice: (json['open_price'] as num).toDouble(),
      highPrice: (json['high_price'] as num).toDouble(),
      lowPrice: (json['low_price'] as num).toDouble(),
      closePrice: (json['close_price'] as num).toDouble(),
      volume: json['volume'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      timeframe: json['timeframe'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'open_price': openPrice,
      'high_price': highPrice,
      'low_price': lowPrice,
      'close_price': closePrice,
      'volume': volume,
      'timestamp': timestamp.toIso8601String(),
      'timeframe': timeframe,
    };
  }

  double get change => closePrice - openPrice;
  double get changePercent => (change / openPrice) * 100;

  @override
  List<Object?> get props => [
        id,
        companyId,
        openPrice,
        highPrice,
        lowPrice,
        closePrice,
        volume,
        timestamp,
        timeframe,
      ];
}
