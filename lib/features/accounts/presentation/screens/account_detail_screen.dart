import 'package:budget_master/domain/models/account.dart';
import 'package:budget_master/features/accounts/application/account_detail_providers.dart';
import 'package:budget_master/features/accounts/presentation/screens/add_account_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AccountDetailScreen extends ConsumerWidget {
  final Account account;
  const AccountDetailScreen({super.key, required this.account});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final breakdown = ref.watch(accountCategoryBreakdownProvider(account.id));
    final currencyFormat = NumberFormat.currency(
      symbol: 'TZS ',
      decimalDigits: 0,
    );

    final totalInflow = breakdown.values.fold(
      0.0,
      (sum, item) => sum + item.deposits,
    );
    final totalOutflow = breakdown.values.fold(
      0.0,
      (sum, item) => sum + item.withdrawals,
    );

    final sortedBreakdown = breakdown.entries.toList()
      ..sort(
        (a, b) => (b.value.deposits - b.value.withdrawals).compareTo(
          a.value.deposits - a.value.withdrawals,
        ),
      );

    return Scaffold(
      appBar: AppBar(
        title: Text(account.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddAccountScreen(account: account),
                ),
              );
            },
            tooltip: 'Edit Account',
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150.0,
            pinned: true,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Current Balance',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimary.withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    currencyFormat.format(account.balance),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
              background: Container(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: 'Total Inflow',
                      value: currencyFormat.format(totalInflow),
                      color: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      title: 'Total Outflow',
                      value: currencyFormat.format(totalOutflow),
                      color: Colors.red.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Category Contribution',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          if (sortedBreakdown.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(
                  child: Text('No transactions for this account yet.'),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final entry = sortedBreakdown[index];
                final categoryName = entry.key;
                final totals = entry.value;
                final netTotal = totals.deposits - totals.withdrawals;

                return ListTile(
                  title: Text(categoryName),
                  subtitle: Text(
                    'In: ${currencyFormat.format(totals.deposits)} | Out: ${currencyFormat.format(totals.withdrawals)}',
                  ),
                  trailing: Text(
                    currencyFormat.format(netTotal),
                    style: TextStyle(
                      color: netTotal >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }, childCount: sortedBreakdown.length),
            ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(title, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
