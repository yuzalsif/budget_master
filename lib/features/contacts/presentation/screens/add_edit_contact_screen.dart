import 'package:budget_master/domain/models/contact.dart';
import 'package:budget_master/features/contacts/application/contact_providers.dart';
import 'package:budget_master/features/contacts/application/contact_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddEditContactScreen extends ConsumerStatefulWidget {
  final Contact? contact;
  const AddEditContactScreen({super.key, this.contact});

  @override
  ConsumerState<AddEditContactScreen> createState() =>
      _AddEditContactScreenState();
}

class _AddEditContactScreenState extends ConsumerState<AddEditContactScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  bool get isEditMode => widget.contact != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveContact() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;

      if (isEditMode) {
        final updatedContact = widget.contact!..name = name;
        ref.read(contactServiceProvider).updateContact(updatedContact);
      } else {
        final newContact = Contact()..name = name;
        ref.read(contactServiceProvider).addContact(newContact);
      }

      ref.invalidate(contactsProvider); 
      Navigator.of(context).pop();
    }
  }

  void _deleteContact() {
    ref.read(contactServiceProvider).deleteContact(widget.contact!.id);
    ref.invalidate(contactsProvider);
    Navigator.of(context).pop(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Contact' : 'Add Contact'),
        actions: [
          if (isEditMode)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteContact,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Contact Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Please enter a name'
                    : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _saveContact,
                icon: const Icon(Icons.save),
                label: const Text('Save Contact'),
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
