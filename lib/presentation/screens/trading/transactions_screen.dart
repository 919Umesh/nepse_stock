import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../business_logic/trading/trading_bloc.dart';
import '../../../business_logic/trading/trading_event.dart';
import '../../../business_logic/trading/trading_state.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  @override
  void initState() {
    super.initState();
    // Load transactions when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TradingBloc>().add(const LoadTransactions());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction History')),
      body: BlocBuilder<TradingBloc, TradingState>(
        builder: (context, state) {
          if (state is TradingLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TransactionsLoaded) {
            final txs = state.transactions;
            if (txs.isEmpty) {
              return const Center(child: Text('No transactions found'));
            }

            return ListView.separated(
              itemCount: txs.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final tx = txs[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.cardBackground,
                    child: Text(tx.type.isNotEmpty ? tx.type[0].toUpperCase() : '?'),
                  ),
                  title: Text('${tx.type.toUpperCase()} • Company:${tx.companyId}', style: AppTextStyles.h4),
                  subtitle: Text(tx.createdAt.toLocal().toString()),
                  trailing: Text(tx.totalAmount.toStringAsFixed(2)),
                );
              },
            );
          }

          if (state is TradingError) {
            return Center(child: Text(state.message));
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
