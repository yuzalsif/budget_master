// lib/features/transactions/application/transaction_providers.dart

import 'package:jbm/features/transactions/domain/transaction_filter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jbm/domain/models/transaction.dart';
import 'package:jbm/features/transactions/application/transaction_service.dart';

final transactionsProvider = StateProvider<List<Transaction>>((ref) {
  return ref.read(transactionServiceProvider).getAllTransactions();
});

// 1. A provider to hold the current filter state.
// The UI will modify this provider when the user selects a filter.
final transactionFilterProvider = StateProvider<TransactionFilter>(
  (ref) => TransactionFilter.initial(),
);

// 2. A new provider that combines the filter and the service.
// It watches the filterProvider. When the filter changes, this provider
// will re-run, call the service with the new filter, and provide the
// updated list to the UI.
final filteredTransactionsProvider = Provider<List<Transaction>>((ref) {
  final filter = ref.watch(transactionFilterProvider);
  final transactionService = ref.read(transactionServiceProvider);

  return transactionService.getFilteredTransactions(filter);
});

// Update the provider to use the new service method and return the new type.
final monthlyCategoryTotalsProvider =
    Provider<Map<String, ({double deposits, double withdrawals})>>((ref) {
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, 1);
      final endDate = DateTime(now.year, now.month + 1, 0);

      return ref
          .read(transactionServiceProvider)
          .getCategoryTotals(startDate: startDate, endDate: endDate);
    });
