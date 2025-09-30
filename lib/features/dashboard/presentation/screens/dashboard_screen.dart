import 'package:jbm/features/debt_credit/presentation/screens/debt_credit_screen.dart';
import 'package:jbm/features/settings/presentation/screens/settings_screen.dart';
import 'package:jbm/features/transactions/presentation/screens/money_transfer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jbm/features/accounts/presentation/screens/accounts_screen.dart';
import 'package:jbm/features/categories/presentation/screens/categories_screen.dart';
import 'package:jbm/features/transactions/presentation/screens/add_edit_transaction_screen.dart';
import 'package:jbm/features/transactions/presentation/screens/transactions_screen.dart';
import 'package:jbm/features/dashboard/application/dashboard_providers.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  late final ScrollController _scrollController;
  bool _isFabVisible = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_isFabVisible) {
        setState(() {
          _isFabVisible = false;
        });
      }
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_isFabVisible) {
        setState(() {
          _isFabVisible = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardData = ref.watch(dashboardDataProvider);
    final currencyFormat = NumberFormat.currency(
      symbol: 'TZS ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 100,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Text('JBM', style: TextStyle(fontSize: 24)),
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
                case 4:
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const MoneyTransferScreen(),
                    ),
                  );
                  break;
                case 5:
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DebtCreditScreen()),
                  );
                  break;
                case 6:
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
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
              const PopupMenuItem(
                value: 4,
                child: ListTile(
                  leading: Icon(Icons.money_outlined),
                  title: Text('Money Transfer'),
                ),
              ),
              const PopupMenuItem(
                value: 5,
                child: ListTile(
                  leading: Icon(Icons.contacts_outlined),
                  title: Text('Debtors/Creditors'),
                ),
              ),
              const PopupMenuItem(
                value: 6,
                child: ListTile(
                  leading: Icon(Icons.settings_outlined),
                  title: Text('Settings'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
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

              // --- Breakdown Charts Section with Pie Charts ---
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Income Breakdown'),
                  Tab(text: 'Expense Breakdown'),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _CategoryPieChart(
                      data: dashboardData.categoryIncomeTotals,
                      baseColor: Colors.green,
                    ),
                    _CategoryPieChart(
                      data: dashboardData.categoryExpenseTotals,
                      baseColor: Colors.red,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

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
                'Debts & Credits',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const DebtCreditScreen(),
                        ),
                      ),
                      borderRadius: BorderRadius.circular(12),
                      child: _KpiCard(
                        title: 'You Are Owed',
                        value: currencyFormat.format(
                          dashboardData.totalDebtors,
                        ),
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const DebtCreditScreen(),
                        ),
                      ),
                      borderRadius: BorderRadius.circular(12),
                      child: _KpiCard(
                        title: 'You Owe',
                        value: currencyFormat.format(
                          dashboardData.totalCreditors,
                        ),
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        offset: _isFabVisible ? Offset.zero : const Offset(0, 2),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const AddEditTransactionScreen(),
              ),
            );
          },
          label: const Text('New Transaction'),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }
}

// --- Helper Widgets for Cleaner Code (KPI and FilterChips are unchanged) ---

class _FilterChips extends ConsumerWidget {
  Future<void> _selectCustomDateRange(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final now = DateTime.now();
    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: now,
    );

    if (pickedRange != null) {
      // If the user picked a range, update the provider state
      ref.read(dashboardFilterProvider.notifier).state = DashboardFilterState(
        filter: DashboardDateFilter.custom,
        dateRange: pickedRange,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We now watch the provider to get the full DashboardFilterState object
    final currentFilterState = ref.watch(dashboardFilterProvider);
    final dateFormat = DateFormat.yMMMd();

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: DashboardDateFilter.values.map((filter) {
          final isSelected = currentFilterState.filter == filter;
          String label;

          // Create a dynamic label for the custom chip
          if (filter == DashboardDateFilter.custom &&
              currentFilterState.dateRange != null &&
              isSelected) {
            label =
                '${dateFormat.format(currentFilterState.dateRange!.start)} - ${dateFormat.format(currentFilterState.dateRange!.end)}';
          } else {
            label = filter.name.replaceAll('this', 'This ');
          }

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (isSelected) {
                if (isSelected) {
                  if (filter == DashboardDateFilter.custom) {
                    // If "Custom" is tapped, show the date picker
                    _selectCustomDateRange(context, ref);
                  } else {
                    // For other filters, update the state normally
                    ref.read(dashboardFilterProvider.notifier).state =
                        DashboardFilterState(filter: filter);
                  }
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

// --- NEW/UPDATED WIDGETS FOR PIE CHART ---

class _CategoryPieChart extends StatelessWidget {
  final Map<String, double> data;
  final Color baseColor;
  const _CategoryPieChart({required this.data, required this.baseColor});

  // A list of colors to use for the pie chart slices.
  static const List<Color> _colorPalette = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.amber,
    Colors.cyan,
    Colors.pink,
    Colors.indigo,
    Colors.teal,
    Colors.brown,
  ];

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          'No data for this period.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    final totalValue = data.values.fold(0.0, (sum, element) => sum + element);
    final chartData = data.entries.toList();

    return Row(
      children: [
        // The Pie Chart
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: chartData.asMap().entries.map((entry) {
                final index = entry.key;
                final dataEntry = entry.value;
                final percentage = (dataEntry.value / totalValue) * 100;

                return PieChartSectionData(
                  color:
                      _colorPalette[index %
                          _colorPalette.length], // Cycle through colors
                  value: dataEntry.value,
                  title: '${percentage.toStringAsFixed(0)}%',
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        // The Legend
        Expanded(flex: 1, child: _ChartLegend(chartData: chartData)),
      ],
    );
  }
}

class _ChartLegend extends StatelessWidget {
  const _ChartLegend({required this.chartData});
  final List<MapEntry<String, double>> chartData;

  // Use the same palette as the chart
  static const List<Color> _colorPalette = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.amber,
    Colors.cyan,
    Colors.pink,
    Colors.indigo,
    Colors.teal,
    Colors.brown,
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: chartData.length,
      itemBuilder: (context, index) {
        final entry = chartData[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                color: _colorPalette[index % _colorPalette.length],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.key,
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
