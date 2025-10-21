import 'package:budget_master/features/transactions/application/transaction_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final accountCategoryBreakdownProvider =
    Provider.family<Map<String, ({double deposits, double withdrawals})>, int>((
      ref,
      accountId,
    ) {
      final transactionService = ref.watch(transactionServiceProvider);
      return transactionService.getCategoryTotalsForAccount(accountId);
    });
