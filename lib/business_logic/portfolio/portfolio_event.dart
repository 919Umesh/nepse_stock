import 'package:equatable/equatable.dart';

/// Portfolio Events
abstract class PortfolioEvent extends Equatable {
  const PortfolioEvent();

  @override
  List<Object?> get props => [];
}

/// Load portfolio
class LoadPortfolio extends PortfolioEvent {
  const LoadPortfolio();
}

/// Load wallet
class LoadWallet extends PortfolioEvent {
  const LoadWallet();
}

/// Refresh portfolio
class RefreshPortfolio extends PortfolioEvent {
  const RefreshPortfolio();
}
