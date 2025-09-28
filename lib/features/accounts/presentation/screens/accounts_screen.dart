// lib/features/accounts/presentation/screens/accounts_screen.dart

import 'package:budget_master/core/providers/database_provider.dart';
import 'package:budget_master/domain/models/account.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_master/features/accounts/application/account_providers.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider to get the async value
    final accountsAsyncValue = ref.watch(accountsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
      ),
      body: accountsAsyncValue.when(
        // Show a loading indicator while fetching data
        loading: () => const Center(child: CircularProgressIndicator()),
        // Show an error message if something goes wrong
        error: (err, stack) => Center(child: Text('Error: $err')),
        // When data is available, display it
        data: (accounts) {
          if (accounts.isEmpty) {
            return const Center(
              child: Text(
                'No accounts yet.\nTap the + button to add one!',
                textAlign: TextAlign.center,
              ),
            );
          }

          // Use a ListView to display the list of accounts
          return ListView.builder(
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              final account = accounts[index];
              return ListTile(
                title: Text(account.name),
                trailing: Text(
                  '${account.balance.toStringAsFixed(2)}', // Format to 2 decimal places
                  style: TextStyle(
                    color: account.balance >= 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // We can add onTap later to see account details
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to an "Add Account" screen
          // For now, let's add a dummy account to test our setup
          _addDummyAccount(ref);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Temporary function to test adding data
  void _addDummyAccount(WidgetRef ref) async {
    final isar = await ref.read(isarProvider.future);

    final newAccount = Account()
      ..name = 'M-PESA'
      ..balance = 5000.0;

    // Write the new account to the database inside a transaction
    await isar.writeTxn(() async {
      await isar.accounts.put(newAccount);
    });
  }
}
