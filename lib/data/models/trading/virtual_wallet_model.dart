import 'package:equatable/equatable.dart';

/// Virtual Wallet Model
class VirtualWalletModel extends Equatable {
  final int id;
  final int userId;
  final double balance;
  final double totalInvested;
  final double totalProfitLoss;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VirtualWalletModel({
    required this.id,
    required this.userId,
    required this.balance,
    required this.totalInvested,
    required this.totalProfitLoss,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VirtualWalletModel.fromJson(Map<String, dynamic> json) {
    return VirtualWalletModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      balance: (json['balance'] as num).toDouble(),
      totalInvested: (json['total_invested'] as num).toDouble(),
      totalProfitLoss: (json['total_profit_loss'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        balance,
        totalInvested,
        totalProfitLoss,
        createdAt,
        updatedAt,
      ];
}
