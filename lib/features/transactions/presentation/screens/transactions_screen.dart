
import 'package:budget_master/features/accounts/application/account_providers.dart';
import 'package:budget_master/features/categories/application/category_providers.dart';
import 'package:budget_master/features/transactions/application/transaction_providers.dart';
import 'package:budget_master/features/transactions/domain/transaction_filter.dart';
import 'package:budget_master/features/transactions/presentation/screens/add_edit_transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_master/domain/models/account.dart';
import 'package:budget_master/domain/models/category.dart';
import 'package:budget_master/domain/models/transaction.dart';

import 'package:intl/intl.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredTransactions = ref.watch(filteredTransactionsProvider);
    final currencyFormat = NumberFormat.currency(
      symbol: 'TZS ',
      decimalDigits: 2,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all_rounded),
            onPressed: () {
              ref.read(transactionFilterProvider.notifier).state =
                  TransactionFilter.initial();
            },
            tooltip: 'Clear Filters',
          ),
        ],
      ),
      body: Column(
        children: [
          _FilterBar(),
          const Divider(height: 1),
          Expanded(
            child: filteredTransactions.isEmpty
                ? const Center(
                    child: Text(
                      'No transactions match your filters.',
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = filteredTransactions[index];
                      final account = transaction.account.target;
                      final category = transaction.category.target;
                      final isWithdrawal =
                          TransactionType.values[transaction.type] ==
                          TransactionType.withdrawal;

                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isWithdrawal
                                ? Colors.red.shade100
                                : Colors.green.shade100,
                            child: Icon(
                              isWithdrawal
                                  ? Icons.arrow_downward_rounded
                                  : Icons.arrow_upward_rounded,
                              color: isWithdrawal ? Colors.red : Colors.green,
                            ),
                          ),
                          title: Text(
                            category?.name ?? 'Uncategorized',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${account?.name ?? 'Unknown Account'}\n${DateFormat.yMMMd().format(transaction.date)}',
                          ),
                          trailing: Text(
                            currencyFormat.format(transaction.amount),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isWithdrawal
                                  ? Colors.red.shade800
                                  : Colors.green.shade800,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddEditTransactionScreen()),
          );
        },
        label: const Text('Add Transaction'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class _FilterBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountsProvider);
    final categories = ref.watch(categoriesProvider);
    final currentFilter = ref.watch(transactionFilterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          FilterChip(
            label: Text(
              accounts
                  .firstWhere(
                    (a) => a.id == currentFilter.accountId,
                    orElse: () => Account()..name = 'Account',
                  )
                  .name,
            ),
            selected: currentFilter.accountId != null,
            onSelected: (selected) {
              if (!selected) {
                ref
                    .read(transactionFilterProvider.notifier)
                    .update((state) => state.copyWith(accountId: null));
              } else {
                _showAccountFilterDialog(context, ref, accounts);
              }
            },
          ),
          const SizedBox(width: 8),

          FilterChip(
            label: Text(
              categories
                  .firstWhere(
                    (c) => c.id == currentFilter.categoryId,
                    orElse: () => Category()..name = 'Category',
                  )
                  .name,
            ),
            selected: currentFilter.categoryId != null,
            onSelected: (selected) {
              if (!selected) {
                ref
                    .read(transactionFilterProvider.notifier)
                    .update((state) => state.copyWith(categoryId: null));
              } else {
                _showCategoryFilterDialog(context, ref, categories);
              }
            },
          ),
          const SizedBox(width: 8),

          PopupMenuButton<DateFilter>(
            initialValue: currentFilter.dateFilter,
            onSelected: (newFilter) {
              ref
                  .read(transactionFilterProvider.notifier)
                  .update((state) => state.copyWith(dateFilter: newFilter));
            },
            itemBuilder: (context) => DateFilter.values.map((filter) {
              return PopupMenuItem(
                value: filter,
                child: Text('By ${filter.name.replaceAll('this', 'This ')}'),
              );
            }).toList(),
            child: Chip(
              avatar: const Icon(Icons.calendar_today, size: 16),
              label: Text(
                'By ${currentFilter.dateFilter.name.replaceAll('this', 'This ')}',
              ),
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
            ),
          ),
        ],
      ),
    );
  }

  void _showAccountFilterDialog(
    BuildContext context,
    WidgetRef ref,
    List<Account> accounts,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Account'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              final account = accounts[index];
              return ListTile(
                title: Text(account.name),
                onTap: () {
                  ref
                      .read(transactionFilterProvider.notifier)
                      .update((state) => state.copyWith(accountId: account.id));
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showCategoryFilterDialog(
    BuildContext context,
    WidgetRef ref,
    List<Category> categories,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Category'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return ListTile(
                title: Text(category.name),
                onTap: () {
                  ref
                      .read(transactionFilterProvider.notifier)
                      .update(
                        (state) => state.copyWith(categoryId: category.id),
                      );
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
