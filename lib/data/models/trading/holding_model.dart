import 'package:equatable/equatable.dart';

/// Holding Model (individual stock holding in portfolio)
class HoldingModel extends Equatable {
  final int id;
  final int userId;
  final int companyId;
  final String companySymbol;
  final String companyName;
  final int quantity;
  final double avgBuyPrice;
  final double totalInvested;
  final double currentPrice;
  final double currentValue;
  final double profitLoss;
  final double profitLossPercent;

  const HoldingModel({
    required this.id,
    required this.userId,
    required this.companyId,
    required this.companySymbol,
    required this.companyName,
    required this.quantity,
    required this.avgBuyPrice,
    required this.totalInvested,
    required this.currentPrice,
    required this.currentValue,
    required this.profitLoss,
    required this.profitLossPercent,
  });

  factory HoldingModel.fromJson(Map<String, dynamic> json) {
    return HoldingModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      companyId: json['company_id'] as int,
      companySymbol: json['company_symbol'] as String,
      companyName: json['company_name'] as String,
      quantity: json['quantity'] as int,
      avgBuyPrice: (json['avg_buy_price'] as num).toDouble(),
      totalInvested: (json['total_invested'] as num).toDouble(),
      currentPrice: (json['current_price'] as num).toDouble(),
      currentValue: (json['current_value'] as num).toDouble(),
      profitLoss: (json['profit_loss'] as num).toDouble(),
      profitLossPercent: (json['profit_loss_percent'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        companyId,
        companySymbol,
        companyName,
        quantity,
        avgBuyPrice,
        totalInvested,
        currentPrice,
        currentValue,
        profitLoss,
        profitLossPercent,
      ];
}
