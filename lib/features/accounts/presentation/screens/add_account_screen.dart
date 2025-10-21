
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_master/domain/models/account.dart';
import 'package:budget_master/features/accounts/application/account_providers.dart';
import 'package:budget_master/features/accounts/application/account_service.dart';

class AddAccountScreen extends ConsumerStatefulWidget {
  final Account? account;
  const AddAccountScreen({super.key, this.account});

  @override
  ConsumerState<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends ConsumerState<AddAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;

  bool get isEditMode => widget.account != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account?.name ?? '');
    _balanceController = TextEditingController(
      text: widget.account?.balance.toStringAsFixed(2) ?? '0.00',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _saveAccount() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final balance = double.tryParse(_balanceController.text) ?? 0.0;

      if (isEditMode) {
        final updatedAccount = widget.account!
          ..name = name
          ..balance = balance;
        ref.read(accountServiceProvider).updateAccount(updatedAccount);
      } else {
        final newAccount = Account()
          ..name = name
          ..balance = balance;
        ref.read(accountServiceProvider).addAccount(newAccount);
      }

      ref.read(accountsProvider.notifier).state = ref
          .read(accountServiceProvider)
          .getAllAccounts();
      Navigator.of(context).pop();
    }
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text(
            'Are you sure you want to delete the "${widget.account!.name}" account? This cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FilledButton.tonal(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
                foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
              ),
              child: const Text('Delete'),
              onPressed: () {
                ref
                    .read(accountServiceProvider)
                    .deleteAccount(widget.account!.id);

                ref.read(accountsProvider.notifier).state = ref
                    .read(accountServiceProvider)
                    .getAllAccounts();

                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Account' : 'Add New Account'),
        actions: [
          if (isEditMode)
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              onPressed: _deleteAccount,
              tooltip: 'Delete Account',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Account Name',
                    hintText: 'e.g., Cash, M-PESA, CRDB Bank',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an account name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _balanceController,
                  decoration: const InputDecoration(
                    labelText: 'Initial Balance',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a balance';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _saveAccount,
                  icon: const Icon(Icons.save_alt_outlined),
                  label: Text(isEditMode ? 'Save Changes' : 'Save Account'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
