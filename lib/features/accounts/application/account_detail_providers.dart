import 'package:jbm/features/transactions/application/transaction_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// A Provider.family to get the category breakdown for a specific account ID.
final accountCategoryBreakdownProvider =
    Provider.family<Map<String, ({double deposits, double withdrawals})>, int>((
      ref,
      accountId,
    ) {
      final transactionService = ref.watch(transactionServiceProvider);
      return transactionService.getCategoryTotalsForAccount(accountId);
    });
