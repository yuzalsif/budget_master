
import 'package:budget_master/features/transactions/domain/transaction_filter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_master/domain/models/transaction.dart';
import 'package:budget_master/features/transactions/application/transaction_service.dart';

final transactionsProvider = StateProvider<List<Transaction>>((ref) {
  return ref.read(transactionServiceProvider).getAllTransactions();
});


final transactionFilterProvider = StateProvider<TransactionFilter>(
  (ref) => TransactionFilter.initial(),
);


final filteredTransactionsProvider = Provider<List<Transaction>>((ref) {
  final filter = ref.watch(transactionFilterProvider);
  final transactionService = ref.read(transactionServiceProvider);

  return transactionService.getFilteredTransactions(filter);
});

final monthlyCategoryTotalsProvider =
    Provider<Map<String, ({double deposits, double withdrawals})>>((ref) {
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, 1);
      final endDate = DateTime(now.year, now.month + 1, 0);

      return ref
          .read(transactionServiceProvider)
          .getCategoryTotals(startDate: startDate, endDate: endDate);
    });
