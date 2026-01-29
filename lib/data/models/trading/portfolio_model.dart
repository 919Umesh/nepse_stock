import 'holding_model.dart';

/// Portfolio Model
class PortfolioModel {
  final double totalValue;
  final double totalInvested;
  final double totalProfitLoss;
  final double profitLossPercent;
  final List<HoldingModel> holdings;

  PortfolioModel({
    required this.totalValue,
    required this.totalInvested,
    required this.totalProfitLoss,
    required this.profitLossPercent,
    required this.holdings,
  });

  factory PortfolioModel.fromJson(Map<String, dynamic> json) {
    return PortfolioModel(
      totalValue: (json['total_value'] as num).toDouble(),
      totalInvested: (json['total_invested'] as num).toDouble(),
      totalProfitLoss: (json['total_profit_loss'] as num).toDouble(),
      profitLossPercent: (json['profit_loss_percent'] as num).toDouble(),
      holdings: (json['holdings'] as List<dynamic>)
          .map((e) => HoldingModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
