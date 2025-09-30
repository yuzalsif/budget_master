import 'package:jbm/domain/models/contact.dart';
import 'package:jbm/features/contacts/application/contact_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// This is the provider that was missing.
// It holds the state (the list of all contacts) for the UI to use.
final contactsProvider = StateProvider<List<Contact>>((ref) {
  // It gets the initial list from our new service.
  return ref.read(contactServiceProvider).getAllContacts();
});
