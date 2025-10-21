
import 'package:budget_master/domain/models/category.dart';
import 'package:budget_master/features/transactions/domain/transaction_filter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_master/core/providers/database_provider.dart';
import 'package:budget_master/domain/models/account.dart';
import 'package:budget_master/domain/models/transaction.dart';
import 'package:budget_master/objectbox.g.dart';

final transactionServiceProvider = Provider<TransactionService>((ref) {
  final store = ref.watch(objectboxProvider).value!;
  return TransactionService(store);  
});

class TransactionService {
  final Store _store;
  late final Box<Transaction> _transactionBox;
  late final Box<Account> _accountBox;

  TransactionService(this._store) {
    _transactionBox = _store.box<Transaction>();
    _accountBox = _store.box<Account>();
  }

  List<Transaction> getAllTransactions() {
    final query = _transactionBox.query()
      ..order(Transaction_.date, flags: Order.descending);
    return query.build().find();
  }

  int? _transferCategoryId;
  int? _getTransferCategoryId() {
    if (_transferCategoryId != null) return _transferCategoryId;
    try {
      final transferCategory = _store
          .box<Category>()
          .query(Category_.name.equals('Transfer', caseSensitive: false))
          .build()
          .findFirst();
      _transferCategoryId = transferCategory?.id;
      return _transferCategoryId;
    } catch (e) {
      return null;
    }
  }

  Map<String, ({double deposits, double withdrawals})>
  getCategoryTotalsForAccount(int accountId) {
    final query = _transactionBox
        .query(Transaction_.account.equals(accountId))
        .build();
    final transactions = query.find();
    query.close();

    final Map<String, ({double deposits, double withdrawals})> totals = {};
    for (var txn in transactions) {
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

  Map<String, ({double deposits, double withdrawals})>
  getAccountTotalsForCategory(int categoryId) {
    final query = _transactionBox
        .query(Transaction_.category.equals(categoryId))
        .build();
    final transactions = query.find();
    query.close();

    final Map<String, ({double deposits, double withdrawals})> totals = {};
    for (var txn in transactions) {
      final accountName = txn.account.target?.name ?? 'Unknown Account';
      var currentTotals =
          totals[accountName] ?? (deposits: 0.0, withdrawals: 0.0);

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

      totals[accountName] = currentTotals;
    }

    return totals;
  }

  Map<String, ({double deposits, double withdrawals})> getCategoryTotals({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final transferId = _getTransferCategoryId();

    final allTransactions = _transactionBox.getAll();

    final transactionsInDateRange = allTransactions.where((txn) {
      final isDateValid =
          (txn.date.isAtSameMomentAs(startDate) ||
              txn.date.isAfter(startDate)) &&
          txn.date.isBefore(endDate);
      final isNotTransfer = txn.category.targetId != transferId;
      return isDateValid && isNotTransfer;
    }).toList();

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

  void performTransfer({
    required Account fromAccount,
    required Category fromCategory,
    required Account toAccount,
    required Category toCategory,
    required double amount,
    required DateTime date,
    String? description,
  }) {
    if (fromAccount.id == toAccount.id && fromCategory.id == toCategory.id) {
      throw Exception(
        "Cannot transfer to the exact same account and category.",
      );
    }
    if (amount <= 0) {
      throw Exception("Transfer amount must be positive.");
    }


    final withdrawalTxn = Transaction()
      ..amount = amount
      ..type = TransactionType.withdrawal.index
      ..date = date
      ..description =
          description ?? 'Transfer to ${toAccount.name} (${toCategory.name})';
    withdrawalTxn.account.target = fromAccount;
    withdrawalTxn.category.target = fromCategory;

    final depositTxn = Transaction()
      ..amount = amount
      ..type = TransactionType.deposit.index
      ..date = date
      ..description =
          description ??
          'Transfer from ${fromAccount.name} (${fromCategory.name})';
    depositTxn.account.target = toAccount;
    depositTxn.category.target = toCategory;

    if (fromAccount.id != toAccount.id) {
      fromAccount.balance -= amount;
      toAccount.balance += amount;
    }

    _store.runInTransaction(TxMode.write, () {
      if (fromAccount.id != toAccount.id) {
        _accountBox.putMany([fromAccount, toAccount]);
      }
      _transactionBox.putMany([withdrawalTxn, depositTxn]);
    });
  }

  void addTransaction(Transaction transaction) {
    final account = transaction.account.target;
    if (account == null) {
      throw Exception('Transaction must have a valid account');
    }

    if (TransactionType.values[transaction.type] ==
        TransactionType.withdrawal) {
      account.balance -= transaction.amount;
    } else {
      account.balance += transaction.amount;
    }

    _store.runInTransaction(TxMode.write, () {
      _accountBox.put(account);
      _transactionBox.put(transaction);
    });
  }

  List<Transaction> getFilteredTransactions(TransactionFilter filter) {
    final queryBuilder = _transactionBox.query()
      ..order(Transaction_.date, flags: Order.descending);

    if (filter.accountId != null) {
      queryBuilder.link(
        Transaction_.account,
        Account_.id.equals(filter.accountId!),
      );
    }

    if (filter.categoryId != null) {
      queryBuilder.link(
        Transaction_.category,
        Category_.id.equals(filter.categoryId!),
      );
    }

    final query = queryBuilder.build();
    final partiallyFilteredList = query.find();
    query.close();

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

  

  ({double income, double expense}) getIncomeExpenseTotals({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final transferId = _getTransferCategoryId();

    final transactions = _transactionBox.getAll().where((txn) {
      final isDateValid =
          (txn.date.isAtSameMomentAs(startDate) ||
              txn.date.isAfter(startDate)) &&
          txn.date.isBefore(endDate);
      final isNotTransfer = txn.category.targetId != transferId;
      return isDateValid && isNotTransfer;
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
    final oldTransaction = _transactionBox.get(updatedTransaction.id);
    if (oldTransaction == null) {
      throw Exception('Original transaction not found for update.');
    }

    final oldAccount = oldTransaction.account.target;

    final newAccount = updatedTransaction.account.target;
    if (newAccount == null) {
      throw Exception('Updated transaction must have a valid account.');
    }

    _store.runInTransaction(TxMode.write, () {
      if (oldAccount != null) {
        if (TransactionType.values[oldTransaction.type] ==
            TransactionType.withdrawal) {
          oldAccount.balance += oldTransaction.amount;
        } else {
          oldAccount.balance -= oldTransaction.amount;
        }
        _accountBox.put(oldAccount);
      }

      if (TransactionType.values[updatedTransaction.type] ==
          TransactionType.withdrawal) {
        newAccount.balance -= updatedTransaction.amount;
      } else {
        newAccount.balance += updatedTransaction.amount;
      }
      _accountBox.put(newAccount);

      _transactionBox.put(updatedTransaction);
    });
  }

  void deleteTransaction(int transactionId) {
    final transaction = _transactionBox.get(transactionId);
    if (transaction == null) {
      throw Exception('Transaction with id $transactionId not found.');
    }

    final account = transaction.account.target;
    if (account == null) {
      _transactionBox.remove(transactionId);
      return;
    }

    _store.runInTransaction(TxMode.write, () {
      if (TransactionType.values[transaction.type] ==
          TransactionType.withdrawal) {
        account.balance += transaction.amount;
      } else {
        account.balance -= transaction.amount;
      }

      _accountBox.put(account);

      _transactionBox.remove(transactionId);
    });
  }
}
