import 'package:equatable/equatable.dart';
import '../../data/models/trading/portfolio_model.dart';
import '../../data/models/trading/virtual_wallet_model.dart';

/// Portfolio States
abstract class PortfolioState extends Equatable {
  const PortfolioState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class PortfolioInitial extends PortfolioState {
  const PortfolioInitial();
}

/// Loading state
class PortfolioLoading extends PortfolioState {
  const PortfolioLoading();
}

/// Portfolio loaded
class PortfolioLoaded extends PortfolioState {
  final PortfolioModel portfolio;
  final VirtualWalletModel wallet;

  const PortfolioLoaded({
    required this.portfolio,
    required this.wallet,
  });

  @override
  List<Object?> get props => [portfolio, wallet];
}

/// Wallet only loaded
class WalletLoaded extends PortfolioState {
  final VirtualWalletModel wallet;

  const WalletLoaded({required this.wallet});

  @override
  List<Object?> get props => [wallet];
}

/// Portfolio error
class PortfolioError extends PortfolioState {
  final String message;

  const PortfolioError({required this.message});

  @override
  List<Object?> get props => [message];
}
