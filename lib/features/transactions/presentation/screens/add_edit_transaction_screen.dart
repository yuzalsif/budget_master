import 'package:budget_master/features/contacts/application/contact_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:budget_master/domain/models/account.dart';
import 'package:budget_master/domain/models/category.dart';
import 'package:budget_master/domain/models/transaction.dart';
import 'package:budget_master/domain/models/contact.dart';

import 'package:budget_master/features/accounts/application/account_providers.dart';
import 'package:budget_master/features/categories/application/category_providers.dart';
import 'package:budget_master/features/transactions/application/transaction_providers.dart';
import 'package:budget_master/features/transactions/application/transaction_service.dart';
import 'package:budget_master/features/dashboard/application/dashboard_providers.dart';
import 'package:budget_master/features/debt_credit/application/debt_credit_service.dart';

class AddEditTransactionScreen extends ConsumerStatefulWidget {
  final Transaction? transaction;
  const AddEditTransactionScreen({super.key, this.transaction});

  @override
  ConsumerState<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState
    extends ConsumerState<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _amountController;
  late final TextEditingController _dateController;
  late final TextEditingController _descriptionController;

  TransactionType _selectedType = TransactionType.withdrawal;
  Account? _selectedAccount;
  Category? _selectedCategory;
  Contact? _selectedContact; // <-- 4. ADD STATE FOR SELECTED CONTACT
  DateTime _selectedDate = DateTime.now();

  bool get isEditMode => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.transaction?.amount.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.transaction?.description ?? '',
    );

    if (isEditMode) {
      final txn = widget.transaction!;
      _selectedType = TransactionType.values[txn.type];
      _selectedDate = txn.date;
      _selectedAccount = txn.account.target;
      _selectedCategory = txn.category.target;
      _selectedContact =
          txn.contact.target; // <-- 5. PRE-POPULATE CONTACT IN EDIT MODE
    }
    _dateController = TextEditingController(
      text: DateFormat.yMMMd().format(_selectedDate),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat.yMMMd().format(_selectedDate);
      });
    }
  }

  void _saveTransaction() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedAccount == null || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an account and a category.'),
        ),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text) ?? 0.0;

    final transaction = isEditMode ? widget.transaction! : Transaction();
    transaction
      ..amount = amount
      ..type = _selectedType.index
      ..date = _selectedDate
      ..description = _descriptionController.text;

    transaction.account.target = _selectedAccount;
    transaction.category.target = _selectedCategory;
    transaction.contact.target =
        _selectedContact; // <-- 6. SET THE CONTACT LINK ON SAVE

    if (isEditMode) {
      ref.read(transactionServiceProvider).updateTransaction(transaction);
    } else {
      ref.read(transactionServiceProvider).addTransaction(transaction);
    }

    // Refresh all relevant providers
    ref.invalidate(accountsProvider);
    ref.invalidate(filteredTransactionsProvider);
    ref.invalidate(dashboardDataProvider);
    ref.invalidate(
      contactBalancesProvider,
    ); // <-- 7. INVALIDATE THE DEBT/CREDIT PROVIDER

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsProvider);
    final categories = ref.watch(categoriesProvider);
    final contacts = ref.watch(
      contactsProvider,
    ); 

    if (!isEditMode) {
      _selectedAccount ??= accounts.isNotEmpty ? accounts.first : null;
      _selectedCategory ??= categories.isNotEmpty ? categories.first : null;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Transaction' : 'New Transaction'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Amount
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.monetization_on_outlined),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (val) =>
                    val!.isEmpty ? 'Please enter an amount' : null,
              ),
              const SizedBox(height: 16),

              // Transaction Type Toggle
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.withdrawal,
                    label: Text('Expense'),
                    icon: Icon(Icons.arrow_downward),
                  ),
                  ButtonSegment(
                    value: TransactionType.deposit,
                    label: Text('Income'),
                    icon: Icon(Icons.arrow_upward),
                  ),
                ],
                selected: {_selectedType},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _selectedType = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Account Dropdown
              DropdownButtonFormField<Account>(
                value:
                    _selectedAccount, // Use value instead of initialValue for better state control
                items: accounts
                    .map(
                      (acc) =>
                          DropdownMenuItem(value: acc, child: Text(acc.name)),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedAccount = val),
                decoration: const InputDecoration(
                  labelText: 'Account',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                ),
                validator: (val) =>
                    val == null ? 'Please select an account' : null,
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<Category>(
                value: _selectedCategory,
                items: categories
                    .map(
                      (cat) =>
                          DropdownMenuItem(value: cat, child: Text(cat.name)),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                validator: (val) =>
                    val == null ? 'Please select a category' : null,
              ),
              const SizedBox(height: 16),

              // --- 9. ADD THE CONTACT DROPDOWN ---
              DropdownButtonFormField<Contact?>(
                // Note the nullable type
                value: _selectedContact,
                items: [
                  // This "None" option allows the user to clear the selection
                  const DropdownMenuItem<Contact?>(
                    value: null,
                    child: Text('None (Regular Transaction)'),
                  ),
                  // The rest of the contacts
                  ...contacts.map(
                    (c) => DropdownMenuItem<Contact?>(
                      value: c,
                      child: Text(c.name),
                    ),
                  ),
                ],
                onChanged: (val) => setState(() => _selectedContact = val),
                decoration: const InputDecoration(
                  labelText: 'Link to Contact (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),

              // Date Picker
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 32),

              ElevatedButton.icon(
                onPressed: _saveTransaction,
                icon: const Icon(Icons.save),
                label: Text(isEditMode ? 'Save Changes' : 'Save Transaction'),
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
