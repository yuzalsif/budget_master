import 'package:budget_master/features/accounts/presentation/screens/accounts_screen.dart';
import 'package:budget_master/features/categories/presentation/screens/categories_screen.dart';
import 'package:budget_master/features/transactions/presentation/screens/add_edit_transaction_screen.dart';
import 'package:budget_master/features/transactions/presentation/screens/transactions_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_master/features/dashboard/application/dashboard_providers.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardData = ref.watch(dashboardDataProvider);
    final currencyFormat = NumberFormat.currency(
      symbol: 'TZS ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 130,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Text('Jackline', style: TextStyle(fontSize: 24)),
        ),
        actions: [
          PopupMenuButton<int>(
            onSelected: (value) {
              switch (value) {
                case 1:
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AccountsScreen()),
                  );
                  break;
                case 2:
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CategoriesScreen()),
                  );
                  break;
                case 3:
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const TransactionsScreen(),
                    ),
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 1,
                child: ListTile(
                  leading: Icon(Icons.account_balance_wallet_outlined),
                  title: Text('Manage Accounts'),
                ),
              ),
              const PopupMenuItem(
                value: 2,
                child: ListTile(
                  leading: Icon(Icons.category_outlined),
                  title: Text('Manage Categories'),
                ),
              ),
              const PopupMenuItem(
                value: 3,
                child: ListTile(
                  leading: Icon(Icons.list_alt_rounded),
                  title: Text('All Transactions'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Filter Chips ---
              _FilterChips(),
              const SizedBox(height: 20),

              // --- KPI Cards ---
              Row(
                children: [
                  Expanded(
                    child: _KpiCard(
                      title: 'Total Balance',
                      value: currencyFormat.format(dashboardData.totalBalance),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _KpiCard(
                      title: 'Net Flow',
                      value: currencyFormat.format(
                        dashboardData.totalIncome - dashboardData.totalExpense,
                      ),
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _KpiCard(
                      title: 'Income',
                      value: currencyFormat.format(dashboardData.totalIncome),
                      color: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _KpiCard(
                      title: 'Expenses',
                      value: currencyFormat.format(dashboardData.totalExpense),
                      color: Colors.red.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- Expense Breakdown Chart ---
              Text(
                'Expense Breakdown',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: _CategoryBarChart(
                  data: dashboardData.categoryExpenseTotals,
                ),
              ),
              const SizedBox(height: 24),

              // --- Account Balances Table ---
              Text(
                'Account Balances',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: dashboardData.accounts.map((account) {
                    return ListTile(
                      leading: const Icon(
                        Icons.account_balance_wallet_outlined,
                      ),
                      title: Text(account.name),
                      trailing: Text(
                        currencyFormat.format(account.balance),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),
              Text(
                'Note: Debtor/Creditor totals will be shown here in a future update.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddEditTransactionScreen()),
          );
        },
        label: const Text('New Transaction'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

// --- Helper Widgets for Cleaner Code ---

class _FilterChips extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(dashboardFilterProvider);
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: DashboardDateFilter.values.map((filter) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(filter.name.replaceAll('this', 'This ')),
              selected: currentFilter == filter,
              onSelected: (isSelected) {
                if (isSelected) {
                  ref.read(dashboardFilterProvider.notifier).state = filter;
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  const _KpiCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.1),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBarChart extends StatelessWidget {
  final Map<String, double> data;
  const _CategoryBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No expense data for this period.'));
    }

    final chartData = data.entries.toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY:
            data.values.reduce((a, b) => a > b ? a : b) *
            1.2, // Add 20% padding to the top
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                final index = value.toInt();
                if (index >= 0 && index < chartData.length) {
                  return SideTitleWidget(
                    meta: meta,
                    space: 4.0,
                    child: Text(
                      chartData[index].key.substring(
                        0,
                        3,
                      ), // Show first 3 letters
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
              reservedSize: 20,
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: chartData.asMap().entries.map((entry) {
          final index = entry.key;
          final categoryData = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: categoryData.value,
                color: Theme.of(context).colorScheme.secondary,
                width: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
