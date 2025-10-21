import 'package:budget_master/core/providers/database_provider.dart';
import 'package:budget_master/domain/models/contact.dart';
import 'package:budget_master/domain/models/transaction.dart';
import 'package:budget_master/objectbox.g.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final debtCreditServiceProvider = Provider<DebtCreditService>((ref) {
  final store = ref.watch(objectboxProvider).value!;
  return DebtCreditService(store);
});

final contactBalancesProvider = Provider<Map<Contact, double>>((ref) {
  return ref.watch(debtCreditServiceProvider).getContactBalances();
});

class DebtCreditService {
  final Store _store;
  late final Box<Transaction> _transactionBox;

  DebtCreditService(this._store) {
    _transactionBox = _store.box<Transaction>();
  }

  Map<Contact, double> getContactBalances() {
    final allTransactions = _transactionBox.getAll();
    final Map<Contact, double> balances = {};

    for (final txn in allTransactions) {
      if (txn.contact.target != null) {
        final contact = txn.contact.target!;
        final amount = txn.amount;

        final value =
            TransactionType.values[txn.type] == TransactionType.withdrawal
            ? amount
            : -amount;

        balances.update(
          contact,
          (existing) => existing + value,
          ifAbsent: () => value,
        );
      }
    }

    balances.removeWhere((key, value) => value.abs() < 0.01);

    return balances;
  }
}
