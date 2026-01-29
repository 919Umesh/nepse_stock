import 'package:equatable/equatable.dart';
import '../../data/models/trading/transaction_model.dart';

/// Trading States
abstract class TradingState extends Equatable {
  const TradingState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class TradingInitial extends TradingState {
  const TradingInitial();
}

/// Loading state
class TradingLoading extends TradingState {
  const TradingLoading();
}

/// Trading success
class TradingSuccess extends TradingState {
  final String message;
  final Map<String, dynamic> data;

  const TradingSuccess({
    required this.message,
    required this.data,
  });

  @override
  List<Object?> get props => [message, data];
}

/// Transactions loaded
class TransactionsLoaded extends TradingState {
  final List<TransactionModel> transactions;

  const TransactionsLoaded({required this.transactions});

  @override
  List<Object?> get props => [transactions];
}

/// Trading error
class TradingError extends TradingState {
  final String message;

  const TradingError({required this.message});

  @override
  List<Object?> get props => [message];
}
