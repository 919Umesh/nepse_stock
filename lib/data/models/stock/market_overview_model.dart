import 'company_model.dart';

/// Market Overview Model
class MarketOverviewModel {
  final int totalCompanies;
  final List<TopGainerLoser> topGainers;
  final List<TopGainerLoser> topLosers;
  final List<CompanyModel> mostActive;

  MarketOverviewModel({
    required this.totalCompanies,
    required this.topGainers,
    required this.topLosers,
    required this.mostActive,
  });

  factory MarketOverviewModel.fromJson(Map<String, dynamic> json) {
    return MarketOverviewModel(
      totalCompanies: json['total_companies'] as int,
      topGainers: (json['top_gainers'] as List<dynamic>)
          .map((e) => TopGainerLoser.fromJson(e as Map<String, dynamic>))
          .toList(),
      topLosers: (json['top_losers'] as List<dynamic>)
          .map((e) => TopGainerLoser.fromJson(e as Map<String, dynamic>))
          .toList(),
      mostActive: (json['most_active'] as List<dynamic>)
          .map((e) => CompanyModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Top Gainer/Loser Model
class TopGainerLoser {
  final int id;
  final String symbol;
  final String name;
  final double currentPrice;
  final double previousPrice;
  final double change;
  final double changePercent;

  TopGainerLoser({
    required this.id,
    required this.symbol,
    required this.name,
    required this.currentPrice,
    required this.previousPrice,
    required this.change,
    required this.changePercent,
  });

  factory TopGainerLoser.fromJson(Map<String, dynamic> json) {
    return TopGainerLoser(
      id: json['id'] as int,
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      currentPrice: (json['current_price'] as num).toDouble(),
      previousPrice: (json['previous_price'] as num).toDouble(),
      change: (json['change'] as num).toDouble(),
      changePercent: (json['change_percent'] as num).toDouble(),
    );
  }
}
