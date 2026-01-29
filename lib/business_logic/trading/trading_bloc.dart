import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/trading_repository.dart';
import '../../data/models/trading/buy_request.dart';
import '../../data/models/trading/sell_request.dart';
import 'trading_event.dart';
import 'trading_state.dart';

/// Trading BLoC
class TradingBloc extends Bloc<TradingEvent, TradingState> {
  final TradingRepository _tradingRepository;

  TradingBloc({required TradingRepository tradingRepository})
      : _tradingRepository = tradingRepository,
        super(const TradingInitial()) {
    on<BuyStockRequested>(_onBuyStockRequested);
    on<SellStockRequested>(_onSellStockRequested);
    on<LoadTransactions>(_onLoadTransactions);
  }

  Future<void> _onBuyStockRequested(
    BuyStockRequested event,
    Emitter<TradingState> emit,
  ) async {
    emit(const TradingLoading());
    
    try {
      final request = BuyRequest(
        symbol: event.symbol,
        quantity: event.quantity,
      );
      
      final result = await _tradingRepository.buyStock(request);
      
      emit(TradingSuccess(
        message: result['message'] ?? 'Stock purchased successfully',
        data: result,
      ));
    } catch (e) {
      emit(TradingError(message: e.toString()));
    }
  }

  Future<void> _onSellStockRequested(
    SellStockRequested event,
    Emitter<TradingState> emit,
  ) async {
    emit(const TradingLoading());
    
    try {
      final request = SellRequest(
        symbol: event.symbol,
        quantity: event.quantity,
      );
      
      final result = await _tradingRepository.sellStock(request);
      
      emit(TradingSuccess(
        message: result['message'] ?? 'Stock sold successfully',
        data: result,
      ));
    } catch (e) {
      emit(TradingError(message: e.toString()));
    }
  }

  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<TradingState> emit,
  ) async {
    emit(const TradingLoading());
    
    try {
      final transactions = await _tradingRepository.getTransactions(
        limit: event.limit,
        offset: event.offset,
      );
      
      emit(TransactionsLoaded(transactions: transactions));
    } catch (e) {
      emit(TradingError(message: e.toString()));
    }
  }
}
