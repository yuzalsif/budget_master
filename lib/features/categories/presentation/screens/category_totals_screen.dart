import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_master/features/transactions/application/transaction_providers.dart';
import 'package:intl/intl.dart';

class CategoryTotalsScreen extends ConsumerWidget {
  const CategoryTotalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Map<String, ({double deposits, double withdrawals})> categoryTotals =
        ref.watch(monthlyCategoryTotalsProvider);

    final currencyFormat = NumberFormat.currency(
      symbol: 'TZS ',
      decimalDigits: 2,
    );
    final monthName = DateFormat.MMMM().format(DateTime.now());

    return Scaffold(
      appBar: AppBar(title: Text('Totals for $monthName')),
      body: categoryTotals.isEmpty
          ? const Center(child: Text('No transactions recorded this month.'))
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: categoryTotals.keys.length,
              itemBuilder: (context, index) {
                final categoryName = categoryTotals.keys.elementAt(index);
                final totals = categoryTotals[categoryName]!;
                final netTotal = totals.deposits - totals.withdrawals;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Text(
                      categoryName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: Text(
                      currencyFormat.format(netTotal),
                      style: TextStyle(
                        fontSize: 16,
                        color: netTotal >= 0
                            ? Colors.green.shade800
                            : Colors.red.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'In: ${currencyFormat.format(totals.deposits)} | Out: ${currencyFormat.format(totals.withdrawals)}',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
