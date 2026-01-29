/// Buy Stock Request Model
class BuyRequest {
  final String symbol;
  final int quantity;

  BuyRequest({
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
