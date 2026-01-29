import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../business_logic/stock/stock_bloc.dart';
import '../../../business_logic/stock/stock_event.dart';
import '../../../business_logic/stock/stock_state.dart';
import '../../../business_logic/trading/trading_bloc.dart';
import '../../../business_logic/trading/trading_event.dart';
import '../../../business_logic/trading/trading_state.dart';
import '../../../business_logic/portfolio/portfolio_bloc.dart';
import '../../../business_logic/portfolio/portfolio_event.dart';
import '../../../business_logic/portfolio/portfolio_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';

class BuyScreen extends StatefulWidget {
  final String symbol;

  const BuyScreen({super.key, required this.symbol});

  @override
  State<BuyScreen> createState() => _BuyScreenState();
}

class _BuyScreenState extends State<BuyScreen> {
  final _quantityController = TextEditingController(text: '10');
  int _quantity = 10;

  @override
  void initState() {
    super.initState();
    context.read<StockBloc>().add(LoadCompanyDetails(symbol: widget.symbol));
    context.read<PortfolioBloc>().add(const LoadWallet());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buy Stock'),
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
              final price = stockState.currentPrice?.closePrice ?? 0;
              
              if (company != null) {
                final totalCost = price * _quantity;
                final commission = totalCost * 0.025; // 2.5% commission
                final totalAmount = totalCost + commission;

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
                                Text('Current Price: ', style: AppTextStyles.labelText),
                                Text(
                                  Formatters.formatCurrency(price),
                                  style: AppTextStyles.valueText.copyWith(
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Available balance
                      BlocBuilder<PortfolioBloc, PortfolioState>(
                        builder: (context, portfolioState) {
                          double availableBalance = 0;
                          if (portfolioState is WalletLoaded) {
                            availableBalance = portfolioState.wallet.balance;
                          } else if (portfolioState is PortfolioLoaded) {
                            availableBalance = portfolioState.wallet.balance;
                          }

                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Available Cash', style: AppTextStyles.bodyMedium),
                                Text(
                                  Formatters.formatCurrency(availableBalance),
                                  style: AppTextStyles.valueText.copyWith(
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Quantity selector
                      Text('Quantity', style: AppTextStyles.h4),
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
                                    _quantity = int.tryParse(value) ?? 10;
                                  });
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () {
                                setState(() {
                                  _quantity++;
                                  _quantityController.text = _quantity.toString();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Order summary
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _buildSummaryRow('Market Price', Formatters.formatCurrency(price)),
                            _buildSummaryRow('Est. Commission (2.5%)', Formatters.formatCurrency(commission)),
                            const Divider(height: 24),
                            _buildSummaryRow(
                              'Total Estimated Cost',
                              Formatters.formatCurrency(totalAmount),
                              isTotal: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Buy button
                      ElevatedButton(
                        onPressed: tradingState is TradingLoading
                            ? null
                            : () {
                                context.read<TradingBloc>().add(
                                      BuyStockRequested(
                                        symbol: widget.symbol,
                                        quantity: _quantity,
                                      ),
                                    );
                              },
                        child: tradingState is TradingLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.backgroundDark,
                                ),
                              )
                            : const Text('Confirm Buy'),
                      ),
                    ],
                  ),
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

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal ? AppTextStyles.bodyLarge : AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: isTotal
                ? AppTextStyles.h4.copyWith(color: AppColors.primaryGreen)
                : AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
