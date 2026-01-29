import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../business_logic/portfolio/portfolio_bloc.dart';
import '../../../business_logic/portfolio/portfolio_event.dart';
import '../../../business_logic/portfolio/portfolio_state.dart';
import '../../../business_logic/stock/stock_bloc.dart';
import '../../../business_logic/stock/stock_event.dart';
import '../../../business_logic/stock/stock_state.dart';
import '../../../business_logic/trading/trading_bloc.dart';
import '../../../business_logic/trading/trading_event.dart';
import '../../../business_logic/trading/trading_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';

class SellScreen extends StatefulWidget {
  final String symbol;

  const SellScreen({super.key, required this.symbol});

  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  final _quantityController = TextEditingController(text: '1');
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    context.read<StockBloc>().add(LoadCompanyDetails(symbol: widget.symbol));
    context.read<PortfolioBloc>().add(const LoadPortfolio());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sell Stock'),
      ),
      body: BlocConsumer<TradingBloc, TradingState>(
        listener: (context, state) {
          if (state is TradingSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.successGreen,
              ),
            );
            context.read<PortfolioBloc>().add(const LoadPortfolio());
            context.pop();
          } else if (state is TradingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.errorRed,
              ),
            );
          }
        },
        builder: (context, tradingState) {
          return BlocBuilder<StockBloc, StockState>(
            builder: (context, stockState) {
              final company = stockState.selectedCompany;
              final currentPrice = stockState.currentPrice?.closePrice ?? 0;

              if (company != null) {
                return BlocBuilder<PortfolioBloc, PortfolioState>(
                  builder: (context, portfolioState) {
                    int ownedQuantity = 0;
                    double avgBuyPrice = 0;

                    if (portfolioState is PortfolioLoaded) {
                      final holding = portfolioState.portfolio.holdings.firstWhere(
                        (h) => h.companySymbol == widget.symbol,
                        orElse: () => portfolioState.portfolio.holdings.first,
                      );
                      if (holding.companySymbol == widget.symbol) {
                        ownedQuantity = holding.quantity;
                        avgBuyPrice = holding.avgBuyPrice;
                      }
                    }

                    final totalValue = currentPrice * _quantity;
                    final profitLoss = (currentPrice - avgBuyPrice) * _quantity;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Company info
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(company.symbol, style: AppTextStyles.stockSymbol),
                                Text(company.name, style: AppTextStyles.companyName),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text('Market Price: ', style: AppTextStyles.labelText),
                                    Text(
                                      Formatters.formatCurrency(currentPrice),
                                      style: AppTextStyles.valueText.copyWith(
                                        color: AppColors.errorRed,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Holdings info
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.errorRed.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Owned Qty', style: AppTextStyles.bodyMedium),
                                    Text(
                                      '$ownedQuantity Units',
                                      style: AppTextStyles.valueText,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Avg Buy Price', style: AppTextStyles.bodyMedium),
                                    Text(
                                      Formatters.formatCurrency(avgBuyPrice),
                                      style: AppTextStyles.valueText,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Quantity selector
                          Text('Quantity to Sell', style: AppTextStyles.h4),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () {
                                    if (_quantity > 1) {
                                      setState(() {
                                        _quantity--;
                                        _quantityController.text = _quantity.toString();
                                      });
                                    }
                                  },
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: _quantityController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.h3,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'UNITS',
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _quantity = int.tryParse(value) ?? 1;
                                      });
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () {
                                    if (_quantity < ownedQuantity) {
                                      setState(() {
                                        _quantity++;
                                        _quantityController.text = _quantity.toString();
                                      });
                                    }
                                  },
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _quantity = ownedQuantity;
                                      _quantityController.text = _quantity.toString();
                                    });
                                  },
                                  child: const Text('MAX'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Transaction summary
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                _buildSummaryRow(
                                  'Estimated Total Value',
                                  Formatters.formatCurrency(totalValue),
                                ),
                                _buildSummaryRow(
                                  'Projected Profit',
                                  Formatters.formatCurrency(profitLoss),
                                  valueColor: profitLoss >= 0
                                      ? AppColors.successGreen
                                      : AppColors.errorRed,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Sell button
                          ElevatedButton(
                            onPressed: tradingState is TradingLoading || ownedQuantity == 0
                                ? null
                                : () {
                                    context.read<TradingBloc>().add(
                                          SellStockRequested(
                                            symbol: widget.symbol,
                                            quantity: _quantity,
                                          ),
                                        );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.errorRed,
                            ),
                            child: tradingState is TradingLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.textPrimary,
                                    ),
                                  )
                                : Text('SELL ${widget.symbol}'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              } else if (stockState.status == StockStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              } else if (stockState.status == StockStatus.failure) {
                return Center(child: Text('Error: ${stockState.error}'));
              }
              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
