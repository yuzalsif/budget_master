import 'package:jbm/domain/models/category.dart';
import 'package:jbm/features/categories/application/category_detail_providers.dart';
import 'package:jbm/features/categories/presentation/screens/add_edit_category_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class CategoryDetailScreen extends ConsumerWidget {
  final Category category;
  const CategoryDetailScreen({super.key, required this.category});

  String _getCategoryTypeName(CategoryType type) {
    return type.name[0].toUpperCase() + type.name.substring(1);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use the .family provider by passing in the category's ID
    final breakdown = ref.watch(categoryAccountBreakdownProvider(category.id));
    final currencyFormat = NumberFormat.currency(
      symbol: 'TZS ',
      decimalDigits: 0,
    );

    // Calculate total inflow and outflow for the summary
    final totalInflow = breakdown.values.fold(
      0.0,
      (sum, item) => sum + item.deposits,
    );
    final totalOutflow = breakdown.values.fold(
      0.0,
      (sum, item) => sum + item.withdrawals,
    );
    final netTotal = totalInflow - totalOutflow;

    final sortedBreakdown = breakdown.entries.toList()
      ..sort(
        (a, b) => (b.value.deposits - b.value.withdrawals).compareTo(
          a.value.deposits - a.value.withdrawals,
        ),
      );

    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
        actions: [
          // The "Edit" button to navigate to the form
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      AddEditCategoryScreen(category: category),
                ),
              );
            },
            tooltip: 'Edit Category',
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // A modern, flexible header
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
                    'Net Total (${_getCategoryTypeName(CategoryType.values[category.type])})',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimary.withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    currencyFormat.format(netTotal),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              background: Container(
                color: netTotal >= 0
                    ? Theme.of(context).colorScheme.primary
                    : Colors.red.shade600,
              ),
            ),
          ),

          // Summary Cards
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

          // Title for the breakdown list
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Breakdown by Account',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // The list of account contributions
          if (sortedBreakdown.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(
                  child: Text('No transactions for this category yet.'),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final entry = sortedBreakdown[index];
                final accountName = entry.key;
                final totals = entry.value;
                final netAccountTotal = totals.deposits - totals.withdrawals;

                return ListTile(
                  title: Text(accountName),
                  subtitle: Text(
                    'In: ${currencyFormat.format(totals.deposits)} | Out: ${currencyFormat.format(totals.withdrawals)}',
                  ),
                  trailing: Text(
                    currencyFormat.format(netAccountTotal),
                    style: TextStyle(
                      color: netAccountTotal >= 0 ? Colors.green : Colors.red,
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

// A helper widget for the summary cards to keep the build method clean
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
