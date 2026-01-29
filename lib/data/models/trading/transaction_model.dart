import 'package:equatable/equatable.dart';

/// Transaction Model
class TransactionModel extends Equatable {
  final int id;
  final int userId;
  final int companyId;
  final String type; // 'buy' or 'sell'
  final int quantity;
  final double pricePerShare;
  final double totalAmount;
  final String status; // 'completed', 'pending', 'failed'
  final DateTime createdAt;

  const TransactionModel({
    required this.id,
    required this.userId,
    required this.companyId,
    required this.type,
    required this.quantity,
    required this.pricePerShare,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      companyId: json['company_id'] as int,
      type: json['type'] as String,
      quantity: json['quantity'] as int,
      pricePerShare: (json['price_per_share'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  bool get isBuy => type == 'buy';
  bool get isSell => type == 'sell';

  @override
  List<Object?> get props => [
        id,
        userId,
        companyId,
        type,
        quantity,
        pricePerShare,
        totalAmount,
        status,
        createdAt,
      ];
}
