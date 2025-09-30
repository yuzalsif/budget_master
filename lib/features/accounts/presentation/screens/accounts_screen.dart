import 'package:jbm/features/accounts/presentation/screens/account_detail_screen.dart';
import 'package:jbm/features/accounts/presentation/screens/add_account_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jbm/domain/models/account.dart';
import 'package:jbm/features/accounts/application/account_providers.dart';

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
              padding: const EdgeInsets.all(8.0), // Add padding around the list
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final account = accounts[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(
                    vertical: 6.0,
                    horizontal: 8.0,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16.0,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      child: Text(
                        account.name.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    title: Text(
                      account.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    trailing: Text(
                      // We'll use a number formatter for better currency display later
                      'TZS ${account.balance.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: account.balance >= 0
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              AccountDetailScreen(account: account),
                        ),
                      );
                      ;
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to the new screen
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddAccountScreen()),
          );
        },
        label: const Text('Add Account'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
