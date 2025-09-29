// lib/features/transactions/presentation/screens/money_transfer_screen.dart

import 'package:budget_master/domain/models/account.dart';
import 'package:budget_master/domain/models/category.dart';
import 'package:budget_master/features/accounts/application/account_providers.dart';
import 'package:budget_master/features/categories/application/category_providers.dart';
import 'package:budget_master/features/dashboard/application/dashboard_providers.dart';
import 'package:budget_master/features/transactions/application/transaction_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MoneyTransferScreen extends ConsumerStatefulWidget {
  const MoneyTransferScreen({super.key});

  @override
  ConsumerState<MoneyTransferScreen> createState() =>
      _MoneyTransferScreenState();
}

class _MoneyTransferScreenState extends ConsumerState<MoneyTransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  Account? _fromAccount;
  Category? _fromCategory;
  Account? _toAccount;
  Category? _toCategory;
  DateTime _selectedDate = DateTime.now();

  void _performTransfer() {
    if (!_formKey.currentState!.validate()) return;

    if (_fromAccount!.id == _toAccount!.id &&
        _fromCategory!.id == _toCategory!.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Source and destination cannot be identical.'),
        ),
      );
      return;
    }

    try {
      ref
          .read(transactionServiceProvider)
          .performTransfer(
            fromAccount: _fromAccount!,
            fromCategory: _fromCategory!,
            toAccount: _toAccount!,
            toCategory: _toCategory!,
            amount: double.parse(_amountController.text),
            date: _selectedDate,
            description: _descriptionController.text,
          );

      ref.invalidate(accountsProvider);
      ref.invalidate(dashboardDataProvider);
      Navigator.of(context).pop();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Transfer successful!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsProvider);
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Move Money')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Amount (unchanged)
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (val) {
                  if (val == null || val.isEmpty)
                    return 'Please enter an amount';
                  if (double.tryParse(val) == null || double.parse(val) <= 0)
                    return 'Enter a valid positive amount';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // --- SOURCE ---
              Text('From', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<Account>(
                      value: _fromAccount,
                      isExpanded: true, // <-- THE FIX
                      itemHeight: kMinInteractiveDimension, // <-- THE FIX
                      items: accounts
                          .map(
                            (acc) => DropdownMenuItem(
                              value: acc,
                              child: Text(
                                acc.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) => setState(() => _fromAccount = val),
                      decoration: const InputDecoration(
                        labelText: 'Account',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => val == null ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<Category>(
                      value: _fromCategory,
                      isExpanded: true, // <-- THE FIX
                      itemHeight: kMinInteractiveDimension, // <-- THE FIX
                      items: categories
                          .map(
                            (cat) => DropdownMenuItem(
                              value: cat,
                              child: Text(
                                cat.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) => setState(() => _fromCategory = val),
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => val == null ? 'Required' : null,
                    ),
                  ),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Icon(Icons.arrow_downward_rounded),
              ),

              // --- DESTINATION ---
              Text('To', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<Account>(
                      value: _toAccount,
                      isExpanded: true, // <-- THE FIX
                      itemHeight: kMinInteractiveDimension, // <-- THE FIX
                      items: accounts
                          .map(
                            (acc) => DropdownMenuItem(
                              value: acc,
                              child: Text(
                                acc.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) => setState(() => _toAccount = val),
                      decoration: const InputDecoration(
                        labelText: 'Account',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => val == null ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<Category>(
                      value: _toCategory,
                      isExpanded: true, // <-- THE FIX
                      itemHeight: kMinInteractiveDimension, // <-- THE FIX
                      items: categories
                          .map(
                            (cat) => DropdownMenuItem(
                              value: cat,
                              child: Text(
                                cat.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) => setState(() => _toCategory = val),
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => val == null ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Description and Button (unchanged)
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),

              ElevatedButton.icon(
                onPressed: _performTransfer,
                icon: const Icon(Icons.sync_alt_rounded),
                label: const Text('Confirm Transfer'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
