// lib/features/debt_credit/application/debt_credit_service.dart
import 'package:jbm/core/providers/database_provider.dart';
import 'package:jbm/domain/models/contact.dart';
import 'package:jbm/domain/models/transaction.dart';
import 'package:jbm/objectbox.g.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final debtCreditServiceProvider = Provider<DebtCreditService>((ref) {
  final store = ref.watch(objectboxProvider).value!;
  return DebtCreditService(store);
});

// This provider will give us a map of each contact and their net balance.
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
      // Only consider transactions that are linked to a contact
      if (txn.contact.target != null) {
        final contact = txn.contact.target!;
        final amount = txn.amount;

        // A withdrawal means the contact now owes us more (or we owe them less).
        // A deposit means the contact now owes us less (or we owe them more).
        final value =
            TransactionType.values[txn.type] == TransactionType.withdrawal
            ? amount
            : -amount;

        // Add the value to the contact's running total.
        balances.update(
          contact,
          (existing) => existing + value,
          ifAbsent: () => value,
        );
      }
    }

    // Remove contacts with a zero balance
    balances.removeWhere((key, value) => value.abs() < 0.01);

    return balances;
  }
}
