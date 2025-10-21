import 'package:budget_master/features/transactions/application/transaction_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final categoryAccountBreakdownProvider =
    Provider.family<Map<String, ({double deposits, double withdrawals})>, int>((
      ref,
      categoryId,
    ) {
      final transactionService = ref.watch(transactionServiceProvider);
      return transactionService.getAccountTotalsForCategory(categoryId);
    });
