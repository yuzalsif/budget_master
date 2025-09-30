import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jbm/domain/models/account.dart';
import 'package:jbm/features/accounts/application/account_providers.dart';
import 'package:jbm/features/transactions/application/transaction_service.dart';
import 'package:jbm/features/debt_credit/application/debt_credit_service.dart';

class DashboardData {
  final double totalBalance;
  final double totalIncome;
  final double totalExpense;
  final List<Account> accounts;
  final Map<String, double> categoryExpenseTotals;
  final Map<String, double> categoryIncomeTotals;

  final double totalDebtors;
  final double totalCreditors;

  DashboardData({
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.accounts,
    required this.categoryExpenseTotals,
    required this.categoryIncomeTotals,

    required this.totalDebtors,
    required this.totalCreditors,
  });
}

enum DashboardDateFilter { thisMonth, thisYear, allTime, custom }

class DashboardFilterState {
  final DashboardDateFilter filter;
  final DateTimeRange? dateRange;

  DashboardFilterState({required this.filter, this.dateRange});
}

final dashboardFilterProvider = StateProvider<DashboardFilterState>(
  (ref) => DashboardFilterState(filter: DashboardDateFilter.thisMonth),
);

final dashboardDataProvider = Provider<DashboardData>((ref) {
  final filterState = ref.watch(dashboardFilterProvider);
  final filter = filterState.filter;
  final now = DateTime.now();
  DateTime startDate;
  DateTime endDate;

  switch (filter) {
    case DashboardDateFilter.thisMonth:
      startDate = DateTime(now.year, now.month, 1);
      endDate = DateTime(now.year, now.month + 1, 1);
      break;
    case DashboardDateFilter.thisYear:
      startDate = DateTime(now.year, 1, 1);
      endDate = DateTime(now.year + 1, 1, 1);
      break;
    case DashboardDateFilter.allTime:
      startDate = DateTime(2000);
      endDate = DateTime(now.year + 1, 1, 1);
      break;
    case DashboardDateFilter.custom:
      final range = filterState.dateRange;
      startDate = range?.start ?? DateTime(now.year, now.month, 1);
      endDate = range != null
          ? DateTime(range.end.year, range.end.month, range.end.day + 1)
          : DateTime(now.year, now.month, now.day + 1);
      break;
  }

  final accounts = ref.watch(accountsProvider);
  final transactionService = ref.read(transactionServiceProvider);
  final contactBalances = ref.watch(contactBalancesProvider);

  final totalBalance = accounts.fold(
    0.0,
    (sum, account) => sum + account.balance,
  );

  final incomeExpense = transactionService.getIncomeExpenseTotals(
    startDate: startDate,
    endDate: endDate,
  );

  final categoryTotalsRaw = transactionService.getCategoryTotals(
    startDate: startDate,
    endDate: endDate,
  );

  final categoryExpenseTotals = Map.fromEntries(
    categoryTotalsRaw.entries
        .where((entry) => entry.value.withdrawals > 0)
        .map((entry) => MapEntry(entry.key, entry.value.withdrawals)),
  );

  final categoryIncomeTotals = Map.fromEntries(
    categoryTotalsRaw.entries
        .where((entry) => entry.value.deposits > 0)
        .map((entry) => MapEntry(entry.key, entry.value.deposits)),
  );

  final totalDebtors = contactBalances.entries
      .where((e) => e.value > 0)
      .fold(0.0, (sum, e) => sum + e.value);

  final totalCreditors = contactBalances.entries
      .where((e) => e.value < 0)
      .fold(0.0, (sum, e) => sum + e.value.abs());

  return DashboardData(
    totalBalance: totalBalance,
    totalIncome: incomeExpense.income,
    totalExpense: incomeExpense.expense,
    accounts: accounts,
    categoryExpenseTotals: categoryExpenseTotals,
    categoryIncomeTotals: categoryIncomeTotals,
    totalDebtors: totalDebtors,
    totalCreditors: totalCreditors,
  );
});
