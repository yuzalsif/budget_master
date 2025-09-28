// lib/features/transactions/application/transaction_service.dart

import 'package:budget_master/features/transactions/domain/transaction_filter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_master/core/providers/database_provider.dart';
import 'package:budget_master/domain/models/account.dart';
import 'package:budget_master/domain/models/transaction.dart';
import 'package:budget_master/objectbox.g.dart';

final transactionServiceProvider = Provider<TransactionService>((ref) {
  final store = ref.watch(objectboxProvider).value!;
  return TransactionService(store); // Pass the whole store
});

class TransactionService {
  final Store _store;
  late final Box<Transaction> _transactionBox;
  late final Box<Account> _accountBox;

  TransactionService(this._store) {
    _transactionBox = _store.box<Transaction>();
    _accountBox = _store.box<Account>();
  }

  // Get all transactions, sorted by date (newest first)
  List<Transaction> getAllTransactions() {
    final query = _transactionBox.query()
      ..order(Transaction_.date, flags: Order.descending);
    return query.build().find();
  }

  /// Adds a new transaction and updates the corresponding account's balance.
  /// This is a critical operation and must be done in a database transaction.
  void addTransaction(Transaction transaction) {
    // 1. Get the account that this transaction is linked to.
    final account = transaction.account.target;
    if (account == null) {
      throw Exception('Transaction must have a valid account');
    }

    // 2. Determine the new balance based on the transaction type.
    if (TransactionType.values[transaction.type] ==
        TransactionType.withdrawal) {
      account.balance -= transaction.amount;
    } else {
      // Deposit
      account.balance += transaction.amount;
    }

    // 3. Use a database transaction to ensure both operations succeed or fail together.
    //    This prevents data corruption (e.g., adding a transaction record
    //    but failing to update the balance).
    _store.runInTransaction(TxMode.write, () {
      // First, save the updated account.
      _accountBox.put(account);
      // Then, save the new transaction.
      _transactionBox.put(transaction);
    });
  }

  // lib/features/transactions/application/transaction_service.dart

  List<Transaction> getFilteredTransactions(TransactionFilter filter) {
    // Start with a base query builder, ordered by date
    final queryBuilder = _transactionBox.query()
      ..order(Transaction_.date, flags: Order.descending);

    // Conditionally add a filter for the account
    if (filter.accountId != null) {
      queryBuilder.link(
        Transaction_.account,
        Account_.id.equals(filter.accountId!),
      );
    }

    // Conditionally add a filter for the category
    if (filter.categoryId != null) {
      queryBuilder.link(
        Transaction_.category,
        Category_.id.equals(filter.categoryId!),
      );
    }

    // --- THIS IS THE CORRECTION ---
    // 1. Build the Query object from the builder.
    final query = queryBuilder.build();
    // 2. Execute find() on the Query object.
    final partiallyFilteredList = query.find();
    // 3. Close the Query object to release resources.
    query.close();
    // ----------------------------

    // The rest of the method is the same and is correct.
    if (filter.dateFilter == DateFilter.allTime) {
      return partiallyFilteredList;
    } else {
      final now = DateTime.now();
      DateTime startDate;
      DateTime endDate;

      if (filter.dateFilter == DateFilter.thisMonth) {
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 1);
      } else {
        // thisYear
        startDate = DateTime(now.year, 1, 1);
        endDate = DateTime(now.year + 1, 1, 1);
      }

      return partiallyFilteredList.where((transaction) {
        return (transaction.date.isAtSameMomentAs(startDate) ||
                transaction.date.isAfter(startDate)) &&
            transaction.date.isBefore(endDate);
      }).toList();
    }
  }

  Map<String, ({double deposits, double withdrawals})> getCategoryTotals({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final allTransactions = _transactionBox.getAll();
    final transactionsInDateRange = allTransactions.where((txn) {
      return (txn.date.isAtSameMomentAs(startDate) ||
              txn.date.isAfter(startDate)) &&
          txn.date.isBefore(endDate);
    }).toList();

    // 3. Process the filtered results (this part is the same as before).
    final Map<String, ({double deposits, double withdrawals})> totals = {};

    for (var txn in transactionsInDateRange) {
      final categoryName = txn.category.target?.name ?? 'Uncategorized';

      var currentTotals =
          totals[categoryName] ?? (deposits: 0.0, withdrawals: 0.0);

      if (TransactionType.values[txn.type] == TransactionType.deposit) {
        currentTotals = (
          deposits: currentTotals.deposits + txn.amount,
          withdrawals: currentTotals.withdrawals,
        );
      } else {
        currentTotals = (
          deposits: currentTotals.deposits,
          withdrawals: currentTotals.withdrawals + txn.amount,
        );
      }

      totals[categoryName] = currentTotals;
    }

    return totals;
  }

  ({double income, double expense}) getIncomeExpenseTotals({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final transactions = _transactionBox.getAll().where((txn) {
      return (txn.date.isAtSameMomentAs(startDate) ||
              txn.date.isAfter(startDate)) &&
          txn.date.isBefore(endDate);
    }).toList();

    double income = 0;
    double expense = 0;

    for (var txn in transactions) {
      if (TransactionType.values[txn.type] == TransactionType.deposit) {
        income += txn.amount;
      } else {
        expense += txn.amount;
      }
    }
    return (income: income, expense: expense);
  }

  void updateTransaction(Transaction updatedTransaction) {
    // 1. Get the original state of the transaction from the DB before any changes.
    final oldTransaction = _transactionBox.get(updatedTransaction.id);
    if (oldTransaction == null) {
      throw Exception('Original transaction not found for update.');
    }

    // 2. Get the account that was originally associated with this transaction.
    final oldAccount = oldTransaction.account.target;

    // 3. Get the account that is now associated with this transaction (it might have changed).
    final newAccount = updatedTransaction.account.target;
    if (newAccount == null) {
      throw Exception('Updated transaction must have a valid account.');
    }

    _store.runInTransaction(TxMode.write, () {
      // --- REVERT THE OLD TRANSACTION ---
      if (oldAccount != null) {
        if (TransactionType.values[oldTransaction.type] ==
            TransactionType.withdrawal) {
          oldAccount.balance +=
              oldTransaction.amount; // Add back the withdrawn amount
        } else {
          // Deposit
          oldAccount.balance -=
              oldTransaction.amount; // Subtract the deposited amount
        }
        // Save the reverted state of the old account.
        // If the old and new account are the same, this will be overwritten in the next step, which is fine.
        _accountBox.put(oldAccount);
      }

      // --- APPLY THE NEW TRANSACTION ---
      if (TransactionType.values[updatedTransaction.type] ==
          TransactionType.withdrawal) {
        newAccount.balance -=
            updatedTransaction.amount; // Subtract the new amount
      } else {
        // Deposit
        newAccount.balance += updatedTransaction.amount; // Add the new amount
      }
      // Save the final state of the new account.
      _accountBox.put(newAccount);

      // --- FINALLY, UPDATE THE TRANSACTION RECORD ITSELF ---
      // This will save all the new details (amount, date, account link, etc.)
      _transactionBox.put(updatedTransaction);
    });
  }

  void deleteTransaction(int transactionId) {
    // 1. Find the transaction we want to delete.
    final transaction = _transactionBox.get(transactionId);
    if (transaction == null) {
      // Or handle this error more gracefully
      throw Exception('Transaction with id $transactionId not found.');
    }

    // 2. Find the associated account.
    final account = transaction.account.target;
    if (account == null) {
      // This case might happen if an account was deleted but transactions were not.
      // For now, we'll just delete the transaction record.
      _transactionBox.remove(transactionId);
      return;
    }

    _store.runInTransaction(TxMode.write, () {
      // 3. Revert the financial impact.
      // If it was a withdrawal, we add the money back.
      // If it was a deposit, we subtract the money.
      if (TransactionType.values[transaction.type] ==
          TransactionType.withdrawal) {
        account.balance += transaction.amount;
      } else {
        // Deposit
        account.balance -= transaction.amount;
      }

      // 4. Save the updated account balance.
      _accountBox.put(account);

      // 5. Finally, delete the transaction record itself.
      _transactionBox.remove(transactionId);
    });
  }
}
