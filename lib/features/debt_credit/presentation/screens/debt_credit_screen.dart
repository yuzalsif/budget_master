import 'package:jbm/features/contacts/presentation/screens/add_edit_contact_screen.dart';
import 'package:jbm/features/debt_credit/application/debt_credit_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DebtCreditScreen extends ConsumerWidget {
  const DebtCreditScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balances = ref.watch(contactBalancesProvider);
    final currencyFormat = NumberFormat.currency(
      symbol: 'TZS ',
      decimalDigits: 0,
    );

    // Separate debtors (they owe me, positive balance) from creditors (I owe them, negative balance)
    final debtors = balances.entries.where((e) => e.value > 0).toList();
    final creditors = balances.entries.where((e) => e.value < 0).toList();

    final totalOwedToMe = debtors.fold(0.0, (sum, e) => sum + e.value);
    final totalIOwe = creditors.fold(0.0, (sum, e) => sum + e.value.abs());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debts & Credits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddEditContactScreen()),
              );
            },
            tooltip: 'Add New Contact',
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: "You Are Owed",
                      value: currencyFormat.format(totalOwedToMe),
                      color: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      title: "You Owe",
                      value: currencyFormat.format(totalIOwe),
                      color: Colors.red.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- DEBTORS LIST ---
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Debtors (Owe You)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          if (debtors.isEmpty)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No one owes you money.'),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final entry = debtors[index];
                return ListTile(
                  leading: const Icon(Icons.arrow_upward, color: Colors.green),
                  title: Text(entry.key.name),
                  trailing: Text(
                    currencyFormat.format(entry.value),
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }, childCount: debtors.length),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // --- CREDITORS LIST ---
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Creditors (You Owe)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          if (creditors.isEmpty)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('You don\'t owe anyone money.'),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final entry = creditors[index];
                return ListTile(
                  leading: const Icon(Icons.arrow_downward, color: Colors.red),
                  title: Text(entry.key.name),
                  trailing: Text(
                    currencyFormat.format(entry.value.abs()),
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }, childCount: creditors.length),
            ),
        ],
      ),
    );
  }
}

// Reusable summary card
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
