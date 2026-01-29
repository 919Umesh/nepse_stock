/// Sell Stock Request Model
class SellRequest {
  final String symbol;
  final int quantity;

  SellRequest({
    required this.symbol,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'quantity': quantity,
    };
  }
}
