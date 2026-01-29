import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/trading_repository.dart';
import 'portfolio_event.dart';
import 'portfolio_state.dart';

/// Portfolio BLoC
class PortfolioBloc extends Bloc<PortfolioEvent, PortfolioState> {
  final TradingRepository _tradingRepository;

  PortfolioBloc({required TradingRepository tradingRepository})
      : _tradingRepository = tradingRepository,
        super(const PortfolioInitial()) {
    on<LoadPortfolio>(_onLoadPortfolio);
    on<LoadWallet>(_onLoadWallet);
    on<RefreshPortfolio>(_onRefreshPortfolio);
  }

  Future<void> _onLoadPortfolio(
    LoadPortfolio event,
    Emitter<PortfolioState> emit,
  ) async {
    emit(const PortfolioLoading());
    
    try {
      final portfolio = await _tradingRepository.getPortfolio();
      final wallet = await _tradingRepository.getWallet();
      
      emit(PortfolioLoaded(
        portfolio: portfolio,
        wallet: wallet,
      ));
    } catch (e) {
      emit(PortfolioError(message: e.toString()));
    }
  }

  Future<void> _onLoadWallet(
    LoadWallet event,
    Emitter<PortfolioState> emit,
  ) async {
    try {
      final wallet = await _tradingRepository.getWallet();
      emit(WalletLoaded(wallet: wallet));
    } catch (e) {
      emit(PortfolioError(message: e.toString()));
    }
  }

  Future<void> _onRefreshPortfolio(
    RefreshPortfolio event,
    Emitter<PortfolioState> emit,
  ) async {
    // Don't show loading state on refresh
    try {
      final portfolio = await _tradingRepository.getPortfolio();
      final wallet = await _tradingRepository.getWallet();
      
      emit(PortfolioLoaded(
        portfolio: portfolio,
        wallet: wallet,
      ));
    } catch (e) {
      emit(PortfolioError(message: e.toString()));
    }
  }
}
