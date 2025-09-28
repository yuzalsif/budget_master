import 'package:budget_master/domain/models/account.dart';
import 'package:budget_master/features/accounts/application/account_providers.dart';
import 'package:budget_master/features/transactions/application/transaction_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- A simple data class to hold all our dashboard data ---
class DashboardData {
  final double totalBalance;
  final double totalIncome;
  final double totalExpense;
  final List<Account> accounts;
  final Map<String, double> categoryExpenseTotals;

  DashboardData({
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.accounts,
    required this.categoryExpenseTotals,
  });
}

// --- Filter provider to control the date range of the dashboard ---
enum DashboardDateFilter { thisMonth, thisYear, allTime }

final dashboardFilterProvider = StateProvider<DashboardDateFilter>(
  (ref) => DashboardDateFilter.thisMonth,
);

// --- The Main Dashboard Data Provider ---
// This provider orchestrates everything. When the filter changes, it re-runs
// and calculates a new DashboardData object.
final dashboardDataProvider = Provider<DashboardData>((ref) {
  // Watch the filter to react to changes
  final filter = ref.watch(dashboardFilterProvider);

  // Get date range based on filter
  final now = DateTime.now();
  DateTime startDate;
  final endDate = now;

  switch (filter) {
    case DashboardDateFilter.thisMonth:
      startDate = DateTime(now.year, now.month, 1);
      break;
    case DashboardDateFilter.thisYear:
      startDate = DateTime(now.year, 1, 1);
      break;
    case DashboardDateFilter.allTime:
      // A very early date to include all transactions
      startDate = DateTime(2000);
      break;
  }

  // Get services and providers we need
  final accounts = ref.watch(accountsProvider);
  final transactionService = ref.read(transactionServiceProvider);

  // Calculate all the values
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

  // We only want the expense part for the bar chart
  final categoryExpenseTotals = Map.fromEntries(
    categoryTotalsRaw.entries
        .where((entry) => entry.value.withdrawals > 0)
        .map((entry) => MapEntry(entry.key, entry.value.withdrawals)),
  );

  // Assemble and return the final data object
  return DashboardData(
    totalBalance: totalBalance,
    totalIncome: incomeExpense.income,
    totalExpense: incomeExpense.expense,
    accounts: accounts,
    categoryExpenseTotals: categoryExpenseTotals,
  );
});
