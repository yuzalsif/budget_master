import 'package:jbm/features/transactions/application/transaction_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// A Provider.family to get the account breakdown for a specific category ID.
final categoryAccountBreakdownProvider =
    Provider.family<Map<String, ({double deposits, double withdrawals})>, int>((
      ref,
      categoryId,
    ) {
      final transactionService = ref.watch(transactionServiceProvider);
      return transactionService.getAccountTotalsForCategory(categoryId);
    });
