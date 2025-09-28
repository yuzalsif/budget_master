import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_master/domain/models/account.dart';
import 'package:budget_master/features/accounts/application/account_providers.dart';
import 'package:budget_master/features/accounts/application/account_service.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the simple StateProvider
    final List<Account> accounts = ref.watch(accountsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Accounts')),
      body: accounts.isEmpty
          ? const Center(
              child: Text(
                'No accounts yet.\nTap the + button to add one!',
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final account = accounts[index];
                return ListTile(
                  title: Text(account.name),
                  trailing: Text(
                    account.balance.toStringAsFixed(2),
                    style: TextStyle(
                      color: account.balance >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addDummyAccount(ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addDummyAccount(WidgetRef ref) {
    // 1. Create the new account
    final newAccount = Account()
      ..name = 'M-PESA'
      ..balance = 5000.0;

    // 2. Use the service to add it to the database
    ref.read(accountServiceProvider).addAccount(newAccount);

    // 3. Manually refresh our UI's state by fetching the new full list
    ref.read(accountsProvider.notifier).state = ref
        .read(accountServiceProvider)
        .getAllAccounts();
  }
}
