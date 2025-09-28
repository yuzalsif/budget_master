// lib/features/dashboard/application/dashboard_providers.dart

import 'package:flutter/material.dart'; // Needed for DateTimeRange
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_master/domain/models/account.dart';
import 'package:budget_master/features/accounts/application/account_providers.dart';
import 'package:budget_master/features/transactions/application/transaction_service.dart';

// --- A simple data class to hold all our dashboard data ---
class DashboardData {
  final double totalBalance;
  final double totalIncome;
  final double totalExpense;
  final List<Account> accounts;
  final Map<String, double> categoryExpenseTotals;
  final Map<String, double> categoryIncomeTotals;

  DashboardData({
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.accounts,
    required this.categoryExpenseTotals,
    required this.categoryIncomeTotals,
  });
}

// --- NEW/UPDATED Filter state management ---
enum DashboardDateFilter { thisMonth, thisYear, allTime, custom }

// A dedicated class to hold our filter state
class DashboardFilterState {
  final DashboardDateFilter filter;
  final DateTimeRange? dateRange; // Nullable for non-custom filters

  DashboardFilterState({required this.filter, this.dateRange});
}

// Update the provider to use our new state class
final dashboardFilterProvider = StateProvider<DashboardFilterState>(
  (ref) => DashboardFilterState(filter: DashboardDateFilter.thisMonth),
);
// --- END of updated filter state management ---

// --- The Main Dashboard Data Provider (Updated to use the new filter state) ---
final dashboardDataProvider = Provider<DashboardData>((ref) {
  // Watch the new filter provider
  final filterState = ref.watch(dashboardFilterProvider);
  final filter = filterState.filter;

  // Get date range based on filter
  final now = DateTime.now();

  DateTime startDate;
  DateTime endDate;

  switch (filter) {
    case DashboardDateFilter.thisMonth:
      startDate = DateTime(now.year, now.month, 1);
      // End date is the first moment of the *next* month
      endDate = DateTime(now.year, now.month + 1, 1);
      break;
    case DashboardDateFilter.thisYear:
      startDate = DateTime(now.year, 1, 1);
      // End date is the first moment of the *next* year
      endDate = DateTime(now.year + 1, 1, 1);
      break;
    case DashboardDateFilter.allTime:
      startDate = DateTime(2000);
      endDate = DateTime(
        now.year + 1,
        1,
        1,
      ); // A future date to include everything
      break;
    case DashboardDateFilter.custom:
      final range = filterState.dateRange;
      startDate = range?.start ?? DateTime(now.year, now.month, 1);
      // For the end date, take the selected day, and go to the *next* day.
      endDate = range != null
          ? DateTime(range.end.year, range.end.month, range.end.day + 1)
          : DateTime(now.year, now.month, now.day + 1);
      break;
  }

  // The rest of this provider is the same as before
  final accounts = ref.watch(accountsProvider);
  final transactionService = ref.read(transactionServiceProvider);

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

  return DashboardData(
    totalBalance: totalBalance,
    totalIncome: incomeExpense.income,
    totalExpense: incomeExpense.expense,
    accounts: accounts,
    categoryExpenseTotals: categoryExpenseTotals,
    categoryIncomeTotals: categoryIncomeTotals,
  );
});
