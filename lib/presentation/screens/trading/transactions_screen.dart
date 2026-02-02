import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../business_logic/trading/trading_bloc.dart';
import '../../../business_logic/trading/trading_event.dart';
import '../../../business_logic/trading/trading_state.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TradingBloc>().add(const LoadTransactions());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction History')),
      body: BlocListener<TradingBloc, TradingState>(
        listener: (context, state) {
          if (state is TradingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: BlocBuilder<TradingBloc, TradingState>(
          builder: (context, state) {
            if (state is TradingLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is TransactionsLoaded) {
              final txs = state.transactions;

              return RefreshIndicator(
                onRefresh: () async {
                  // Reload first page
                  context.read<TradingBloc>().add(const LoadTransactions(limit: 50, offset: 0));
                  // Wait for either loaded or error
                  await context.read<TradingBloc>().stream.firstWhere(
                    (s) => s is TransactionsLoaded || s is TradingError,
                  );
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: txs.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // Summary card
                      final totalAmount = txs.fold<double>(0, (p, e) => p + e.totalAmount);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: AppColors.cardGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Transactions', style: AppTextStyles.h4.copyWith(color: Colors.white)),
                                  const SizedBox(height: 8),
                                  Text('${txs.length} items', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(Formatters.formatCurrency(totalAmount), style: AppTextStyles.h3.copyWith(color: Colors.white)),
                                  const SizedBox(height: 6),
                                  Text('Total', style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final tx = txs[index - 1];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        // slightly larger vertical padding to avoid tiny overflow on some devices
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        leading: CircleAvatar(
                          backgroundColor: AppColors.cardBackground,
                          child: Text(tx.type.isNotEmpty ? tx.type[0].toUpperCase() : '?'),
                        ),
                        title: Text(tx.type.toUpperCase(), style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                        subtitle: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 2),
                            Text(
                              'Company: ${tx.companyId}',
                              style: AppTextStyles.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              Formatters.formatDateTime(tx.createdAt),
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(Formatters.formatCurrency(tx.totalAmount), style: AppTextStyles.valueText.copyWith(fontSize: 14)),
                            const SizedBox(height: 4),
                            _buildStatusChip(tx.status),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }

            if (state is TradingError) {
              return Center(child: Text(state.message));
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final color = status == 'completed'
        ? AppColors.successGreen
        : (status == 'pending' ? AppColors.warningOrange : AppColors.errorRed);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: AppTextStyles.bodySmall.copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}
